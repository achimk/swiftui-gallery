import Combine
import Foundation

public typealias PollingOperation<Value> = (@escaping (Value) -> Void) -> Cancellable
public typealias PollingTimerScheduler = (TimeInterval, @escaping () -> Void) -> Cancellable

public enum PollingState {
    case idle
    case running
}

public enum PollingTimeInterval {
    case constant(TimeInterval)
    case generate(() -> TimeInterval)

    public func next() -> TimeInterval {
        switch self {
        case let .constant(timeInterval): return timeInterval
        case let .generate(timeIntervalGenerator): return timeIntervalGenerator()
        }
    }
}

public final class PollingProcess<Value> {
    private let timeInterval: PollingTimeInterval
    private let timerScheduler: PollingTimerScheduler
    private let canScheduleNext: () -> Bool
    private let operation: PollingOperation<Value>
    private let statePublisher = PassthroughSubject<PollingState, Never>()
    private let valuePublisher = PassthroughSubject<Value, Never>()
    private var timerCancellable: Cancellable? {
        willSet { timerCancellable?.cancel() }
    }

    private var operationCancellable: Cancellable? {
        willSet { operationCancellable?.cancel() }
    }

    public private(set) var state: PollingState = .idle {
        didSet { statePublisher.send(state) }
    }

    public init(
        timeInterval: PollingTimeInterval,
        timerScheduler: @escaping PollingTimerScheduler = scheduleTimer(timeInterval:callback:),
        canScheduleNext: @escaping () -> Bool = { true },
        operation: @escaping PollingOperation<Value>
    ) {
        self.timeInterval = timeInterval
        self.timerScheduler = timerScheduler
        self.canScheduleNext = canScheduleNext
        self.operation = operation
    }

    deinit {
        invalidatePolling()
    }

    public func start(immediately: Bool = false) {
        if state != .running {
            state = .running
            if immediately {
                runAndSchedule()
            } else {
                schedulePolling()
            }
        }
    }

    public func stop() {
        if state == .running {
            state = .idle
            invalidatePolling()
        }
    }

    private func runAndSchedule() {
        guard state == .running else {
            return
        }
        handlePolling()
    }

    private func schedulePolling() {
        guard state == .running else {
            return
        }
        guard canScheduleNext() else {
            stop()
            return
        }
        timerCancellable = timerScheduler(timeInterval.next()) { [weak self] in
            self?.handlePolling()
        }
    }

    private func handlePolling() {
        operationCancellable = operation { [weak self, valuePublisher] value in
            valuePublisher.send(value)
            self?.schedulePolling()
        }
    }

    private func invalidatePolling() {
        timerCancellable = nil
        operationCancellable = nil
    }
}

// MARK: - Observing

public extension PollingProcess {
    func observePollingState(_ callback: @escaping (PollingState) -> Void) -> Cancellable {
        statePublisher.sink(receiveValue: callback)
    }

    func observePollingValue(_ callback: @escaping (Value) -> Void) -> Cancellable {
        valuePublisher.sink(receiveValue: callback)
    }
}

// MARK: - Async / Await support

public extension PollingProcess {
    convenience init(
        timeInterval: PollingTimeInterval,
        timerScheduler: @escaping PollingTimerScheduler = scheduleTimer(timeInterval:callback:),
        canScheduleNext: @escaping () -> Bool = { true },
        operation: @escaping () async -> Value
    ) {
        let taskOperation: (@escaping (Value) -> Void) -> Cancellable = { completion in
            let task = Task { @MainActor in
                let value = await operation()
                if !Task.isCancelled {
                    completion(value)
                }
            }
            return AnyCancellable {
                task.cancel()
            }
        }

        self.init(
            timeInterval: timeInterval,
            timerScheduler: timerScheduler,
            canScheduleNext: canScheduleNext,
            operation: taskOperation
        )
    }
}

// MARK: - Publisher support

public extension PollingProcess {
    convenience init(
        timeInterval: PollingTimeInterval,
        timerScheduler: @escaping PollingTimerScheduler = scheduleTimer(timeInterval:callback:),
        canScheduleNext: @escaping () -> Bool = { true },
        operation: @escaping () -> AnyPublisher<Value, Never>
    ) {
        let publishOperation: (@escaping (Value) -> Void) -> Cancellable = { completion in
            operation()
                .first()
                .sink(receiveValue: completion)
        }

        self.init(
            timeInterval: timeInterval,
            timerScheduler: timerScheduler,
            canScheduleNext: canScheduleNext,
            operation: publishOperation
        )
    }
}

// MARK: - Helpers

public extension PollingProcess {
    static func scheduleTimer(
        timeInterval: TimeInterval,
        callback: @escaping () -> Void
    ) -> Cancellable {
        let timer = Timer.scheduledTimer(
            withTimeInterval: timeInterval,
            repeats: false,
            block: { _ in
                callback()
            }
        )
        return AnyCancellable {
            timer.invalidate()
        }
    }
}
