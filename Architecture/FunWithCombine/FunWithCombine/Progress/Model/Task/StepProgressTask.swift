import Foundation

final class StepProgressTask {
    private let operation: StepProgressOperation
    private var continuation: CheckedContinuation<Void, Error>?

    var onUpdate: ((Int, StepProgressState) -> Void)?

    init(
        request: StepProgressRequest,
        timerScheduler: @escaping TimerScheduler = ProgressTimer.schedule(with:block:)
    ) {
        operation = StepProgressOperation(
            request: request,
            timerScheduler: timerScheduler
        )

        operation.onUpdate = { [weak self] step, state in
            self?.handle(step: step, state: state)
        }
    }

    deinit {
        cancel()
    }

    @MainActor
    func start() async throws {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { [operation] (continuation: CheckedContinuation<Void, Error>) in
                assert(Thread.isMainThread)
                guard operation.state == .initial else {
                    continuation.resume(throwing: StepProgressError.alreadyRunning)
                    return
                }
                self.continuation = continuation
                operation.start()
            }
        } onCancel: {
            operation.cancel()
        }
    }

    func cancel() {
        operation.cancel()
    }

    private func handle(step: Int, state: StepProgressState) {
        onUpdate?(step, state)

        switch state {
        case .initial, .running:
            break
        case .cancelled:
            continuation?.resume(throwing: StepProgressError.cancelInvoked)
            continuation = nil
        case .finished:
            continuation?.resume(returning: ())
            continuation = nil
        }
    }
}
