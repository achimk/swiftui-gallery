import Combine
import Foundation

public final class PollingScheduler<Value> {
    private let process: PollingProcess<Value>
    private let queue: PollingQueue<Value>
    private let statePublisher = PassthroughSubject<PollingState, Never>()
    private let valuePublisher = PassthroughSubject<Value, Never>()
    private var cancellables = Set<AnyCancellable>()

    public init(queue: PollingQueue<Value>) {
        self.queue = queue
        process = PollingProcess(
            timeInterval: .generate(queue.dequeuePollingTimeInterval),
            canScheduleNext: queue.canDequeuePollingOperation,
            operation: { completion in
                let operation = queue.dequeuePollingOperation()
                return operation(completion)
            }
        )
        process.observePollingState { [weak self] state in
            self?.pollingStateUpdated(to: state)
        }.store(in: &cancellables)
        process.observePollingValue { [weak self] value in
            self?.operationCompleted(with: value)
        }.store(in: &cancellables)
    }
}

public extension PollingScheduler {
    func start() {
        process.start()
    }

    func stop() {
        process.stop()
    }
}

extension PollingScheduler {
    public func observePollingState(_ callback: @escaping (PollingState) -> Void) -> Cancellable {
        statePublisher.sink(receiveValue: callback)
    }

    public func observePollingValue(_ callback: @escaping (Value) -> Void) -> Cancellable {
        valuePublisher.sink(receiveValue: callback)
    }

    private func pollingStateUpdated(to state: PollingState) {
        queue.pollingStateUpdated(to: state)
        statePublisher.send(state)
    }

    private func operationCompleted(with value: Value) {
        queue.operationCompleted(with: value)
        valuePublisher.send(value)
    }
}

open class PollingQueue<Value> {
    public init() {}

    open func pollingStateUpdated(to _: PollingState) {}

    open func canDequeuePollingOperation() -> Bool {
        false
    }

    open func dequeuePollingTimeInterval() -> TimeInterval {
        fatalError()
    }

    open func dequeuePollingOperation() -> PollingOperation<Value> {
        fatalError()
    }

    open func operationCompleted(with _: Value) {}
}

public final class ListPollingQueue<Value>: PollingQueue<Value> {
    private var operations: [OperationItem] = []
    private var currentIndex: Int = 0

    override public func pollingStateUpdated(to state: PollingState) {
        switch state {
        case .running:
            break
        case .idle:
            currentIndex = 0
        }
    }

    override public func canDequeuePollingOperation() -> Bool {
        if operations.isEmpty {
            return false
        }
        return currentIndex < operations.count
    }

    override public func dequeuePollingTimeInterval() -> TimeInterval {
        operations[currentIndex].timeInterval
    }

    override public func dequeuePollingOperation() -> PollingOperation<Value> {
        operations[currentIndex].operation
    }

    override public func operationCompleted(with _: Value) {
        currentIndex += 1
    }
}

public extension ListPollingQueue {
    @discardableResult
    func schedule(at timeInterval: TimeInterval, action: @escaping () -> Value) -> Self {
        schedule(at: timeInterval, operation: { completion in
            completion(action())
            return AnyCancellable {}
        })
    }

    @discardableResult
    func schedule(at timeInterval: TimeInterval, operation: @escaping PollingOperation<Value>) -> Self {
        let operationItem = OperationItem(
            timeInterval: timeInterval,
            operation: operation
        )
        operations.append(operationItem)
        return self
    }
}

extension ListPollingQueue {
    private struct OperationItem {
        let timeInterval: TimeInterval
        let operation: PollingOperation<Value>
    }
}

public final class CircularPollingQueue<Value>: PollingQueue<Value> {
    private var operations: [OperationItem] = []
    private var offset: Int = 0
    private var currentIndex: Int {
        offset % operations.count
    }

    override public func pollingStateUpdated(to state: PollingState) {
        switch state {
        case .running:
            break
        case .idle:
            offset = 0
        }
    }

    override public func canDequeuePollingOperation() -> Bool {
        !operations.isEmpty
    }

    override public func dequeuePollingTimeInterval() -> TimeInterval {
        operations[currentIndex].timeInterval
    }

    override public func dequeuePollingOperation() -> PollingOperation<Value> {
        operations[currentIndex].operation
    }

    override public func operationCompleted(with _: Value) {
        offset += 1
    }
}

public extension CircularPollingQueue {
    @discardableResult
    func schedule(at timeInterval: TimeInterval, action: @escaping () -> Value) -> Self {
        schedule(at: timeInterval, operation: { completion in
            completion(action())
            return AnyCancellable {}
        })
    }

    @discardableResult
    func schedule(at timeInterval: TimeInterval, operation: @escaping PollingOperation<Value>) -> Self {
        let operationItem = OperationItem(
            timeInterval: timeInterval,
            operation: operation
        )
        operations.append(operationItem)
        return self
    }
}

extension CircularPollingQueue {
    private struct OperationItem {
        let timeInterval: TimeInterval
        let operation: PollingOperation<Value>
    }
}
