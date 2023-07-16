import Foundation

typealias TimerInvalidate = () -> Void
typealias TimerScheduler = (TimeInterval, @escaping () -> Void) -> TimerInvalidate

final class ProgressOperation {
    @frozen
    enum State: Equatable {
        case initial
        case running
        case cancelled
        case finished
    }

    private let timerScheduler: TimerScheduler
    private let numberOfSteps: Int
    private let stepDuration: TimeInterval
    private var invalidate: (() -> Void)?
    private(set) var currentStep: Int = 0 {
        didSet { onUpdate?(currentStep, state) }
    }

    private(set) var state: State = .initial {
        didSet { onUpdate?(currentStep, state) }
    }

    var onUpdate: ((Int, State) -> Void)? {
        didSet { onUpdate?(currentStep, state) }
    }

    init(
        numberOfSteps: Int,
        stepDuration: TimeInterval,
        timerScheduler: @escaping TimerScheduler = ProgressTimer.schedule(with:block:)
    ) {
        self.numberOfSteps = max(0, numberOfSteps)
        self.stepDuration = max(0.0, stepDuration)
        self.timerScheduler = timerScheduler
    }

    deinit {
        cancel()
    }

    func cancel() {
        guard state == .running || state == .initial else {
            return
        }
        state = .cancelled
        invalidate?()
        invalidate = nil
    }

    func start() {
        guard state == .initial else {
            return
        }
        state = .running
        scheduleStepIfNeeded()
    }

    private func scheduleStepIfNeeded() {
        guard state == .running else {
            return
        }

        if currentStep < numberOfSteps {
            invalidate = timerScheduler(stepDuration) { [weak self] in
                self?.currentStep += 1
                self?.scheduleStepIfNeeded()
            }
        } else {
            state = .finished
        }
    }
}

final class ProgressTimer {
    private var timer: Timer?

    deinit {
        invalidate()
    }

    func schedule(with timeInterval: TimeInterval, block: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in block() }
    }

    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}

extension ProgressTimer {
    static func schedule(with timeInterval: TimeInterval, block: @escaping () -> Void) -> TimerInvalidate {
        let timer = ProgressTimer()
        timer.schedule(with: timeInterval, block: block)
        return timer.invalidate
    }
}
