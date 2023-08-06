import Combine
import Foundation

public enum PollingState {
    case idle
    case running
}

public typealias TimerScheduler = (TimeInterval, @escaping () -> Void) -> Cancellable

public final class PollingProcess<Value> {
    private let timeInterval: TimeInterval
    private let timerSchduler: TimerScheduler
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
        timerScheduler: @escaping TimerScheduler = defaultTimeScheduler,
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

extension PollingProcess {
    func observePollingState(_ callback: @escaping (PollingState) -> Void) -> Cancellable {
        statePublisher.sink(receiveValue: callback)
    }

    func observePollingValue(_ callback: @escaping (Value) -> Void) -> Cancellable {
        valuePublisher.sink(receiveValue: callback)
    }
}

public func defaultTimeScheduler(
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
