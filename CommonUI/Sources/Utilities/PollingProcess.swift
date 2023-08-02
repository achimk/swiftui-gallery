import Foundation

public enum PollingState {
    case idle
    case running
}

public typealias PollingCompletion = () -> Void
public typealias PollingInvalidate = () -> Void
public typealias PollingScheduler = (TimeInterval, @escaping () -> PollingInvalidate) -> PollingInvalidate

public final class PollingProcess {
    private let timeInterval: TimeInterval
    private let pollingScheduler: PollingScheduler
    private let perform: (@escaping PollingCompletion) -> PollingInvalidate
    private var invalidate: PollingInvalidate?

    @Published
    public private(set) var state: PollingState = .idle

    public init(
        timeInterval: TimeInterval,
        perform: @escaping (@escaping PollingCompletion) -> PollingInvalidate,
        pollingScheduler: @escaping PollingScheduler = PollingProcess.defaultScheduler
    ) {
        self.timeInterval = timeInterval
        self.perform = perform
        self.pollingScheduler = pollingScheduler
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

        let completion: PollingCompletion = { [weak self] in
            self?.schedulePolling()
        }

        invalidate = perform(completion)
    }

    private func schedulePolling() {
        guard state == .running else {
            return
        }

        let completion: PollingCompletion = { [weak self] in
            self?.schedulePolling()
        }

        invalidate = pollingScheduler(timeInterval) { [perform] in
            perform(completion)
        }
    }

    private func invalidatePolling() {
        invalidate?()
        invalidate = nil
    }
}

extension PollingProcess {
    private class PollingTimer {
        private let timeInterval: TimeInterval
        private let callback: () -> PollingInvalidate
        private var timer: Timer?
        private var cancellation: PollingInvalidate?

        init(
            timeInterval: TimeInterval,
            callback: @escaping () -> PollingInvalidate
        ) {
            self.timeInterval = timeInterval
            self.callback = callback
        }

        func schedule() {
            timer = Timer.scheduledTimer(
                withTimeInterval: timeInterval,
                repeats: false,
                block: { [weak self] _ in
                    self?.perform()
                }
            )
        }

        func perform() {
            cancellation = callback()
        }

        func invalidate() {
            cancellation?()
            timer?.invalidate()
            timer = nil
        }
    }

    public static let defaultScheduler: PollingScheduler = { timeInterval, callback in
        let timer = PollingTimer(timeInterval: timeInterval, callback: callback)
        timer.schedule()
        return timer.invalidate
    }
}
