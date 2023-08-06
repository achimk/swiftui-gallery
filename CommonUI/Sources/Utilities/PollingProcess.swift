import Combine
import Foundation

public enum PollingState {
    case idle
    case running
}

public typealias PollingTimerScheduler = (TimeInterval, @escaping () -> Void) -> Cancellable

public final class PollingProcess<Value> {
    private let timeInterval: TimeInterval
    private let timerSchduler: PollingTimerScheduler
    private let operation: (@escaping (Value) -> Void) -> Cancellable
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
        timeInterval: TimeInterval,
        timerScheduler: @escaping PollingTimerScheduler = scheduleTimer(timeInterval:callback:),
        operation: @escaping (@escaping (Value) -> Void) -> Cancellable
    ) {
        self.timeInterval = timeInterval
        timerSchduler = timerScheduler
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
        timerCancellable = timerSchduler(timeInterval) { [weak self] in
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
        timeInterval: TimeInterval,
        timerScheduler: @escaping PollingTimerScheduler = scheduleTimer(timeInterval:callback:),
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
            operation: taskOperation
        )
    }
}

// MARK: - Publisher support

public extension PollingProcess {
    convenience init(
        timeInterval: TimeInterval,
        timerScheduler: @escaping PollingTimerScheduler = scheduleTimer(timeInterval:callback:),
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
