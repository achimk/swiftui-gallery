import Foundation

final class StepProgressOperation {
    private let timerScheduler: TimerScheduler
    private var invalidate: (() -> Void)?
    private(set) var currentStep: Int = 0 {
        didSet { onUpdate?(currentStep, state) }
    }

    private(set) var state: StepProgressState = .initial {
        didSet { onUpdate?(currentStep, state) }
    }

    let numberOfSteps: Int
    let stepDuration: TimeInterval
    var onUpdate: ((Int, StepProgressState) -> Void)?

    convenience init(
        request: StepProgressRequest,
        timerScheduler: @escaping TimerScheduler = ProgressTimer.schedule(with:block:)
    ) {
        self.init(
            numberOfSteps: request.numberOfSteps,
            stepDuration: request.stepDuration,
            timerScheduler: timerScheduler
        )
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
