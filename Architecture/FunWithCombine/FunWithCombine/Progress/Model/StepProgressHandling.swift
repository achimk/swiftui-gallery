import Foundation

protocol StepProgressDelegate: AnyObject {
    func progressDidUpdate(_ handler: StepProgressHandling, step: Int, state: StepProgressState)
}

protocol StepProgressHandling {
    func start()
    func cancel()
}

final class StepProgressOperationHandler: StepProgressHandling {
    private let operation: StepProgressOperation

    weak var delegate: StepProgressDelegate?

    init(
        request: StepProgressRequest,
        timerScheduler: @escaping TimerScheduler = ProgressTimer.schedule(with:block:)
    ) {
        operation = StepProgressOperation(
            request: request,
            timerScheduler: timerScheduler
        )

        operation.onUpdate = { [weak self] step, state in
            self?.operationUpdated(step: step, state: state)
        }
    }

    func start() {
        operation.start()
    }

    func cancel() {
        operation.cancel()
    }

    private func operationUpdated(step: Int, state: StepProgressState) {
        delegate?.progressDidUpdate(self, step: step, state: state)
    }
}

final class StepProgressAsyncHandler: StepProgressHandling {
    private let task: StepProgressTask

    weak var delegate: StepProgressDelegate?

    init(
        request: StepProgressRequest,
        timerScheduler: @escaping TimerScheduler = ProgressTimer.schedule(with:block:)
    ) {
        task = StepProgressTask(
            request: request,
            timerScheduler: timerScheduler
        )

        task.onUpdate = { [weak self] step, state in
            self?.taskUpdated(step: step, state: state)
        }
    }

    func start() {
        Task { @MainActor in
            do {
                assert(Thread.isMainThread)
                try await task.start()
            } catch {
                print("=> failed: \(error)")
            }
        }
    }

    func cancel() {
        task.cancel()
    }

    private func taskUpdated(step: Int, state: StepProgressState) {
        delegate?.progressDidUpdate(self, step: step, state: state)
    }
}

final class StepProgressTaskHandler: StepProgressHandling {
    private var task: Task<Void, Error>?
    private let stepProgressTask: StepProgressTask

    weak var delegate: StepProgressDelegate?

    init(
        request: StepProgressRequest,
        timerScheduler: @escaping TimerScheduler = ProgressTimer.schedule(with:block:)
    ) {
        stepProgressTask = StepProgressTask(
            request: request,
            timerScheduler: timerScheduler
        )

        stepProgressTask.onUpdate = { [weak self] step, state in
            self?.taskUpdated(step: step, state: state)
        }
    }

    func start() {
        task = Task { @MainActor in
            do {
                assert(Thread.isMainThread)
                try await stepProgressTask.start()
                try Task.checkCancellation()
            } catch is CancellationError {
                print("=> cancelled")
            } catch {
                print("=> failed: \(error)")
            }
        }
    }

    func cancel() {
        task?.cancel()
    }

    private func taskUpdated(step: Int, state: StepProgressState) {
        delegate?.progressDidUpdate(self, step: step, state: state)
    }
}

typealias StepProgressCancelation = () -> Void

class StepProgressManager {
    private var currentHandler: StepProgressHandling?
    private let stepHandlerFactory: (StepProgressRequest, StepProgressDelegate) -> StepProgressHandling

    init(stepHandlerFactory: @escaping (StepProgressRequest, StepProgressDelegate) -> StepProgressHandling) {
        self.stepHandlerFactory = stepHandlerFactory
    }

    func canSchedule() -> Bool {
        currentHandler == nil
    }

    func schedule(with request: StepProgressRequest, delegate: StepProgressDelegate) throws -> StepProgressCancelation {
        guard canSchedule() else {
            throw StepProgressError.alreadyRunning
        }

        let proxyDelegate = ProxyStepProgressDelegate()
        proxyDelegate.onProgressDidUpdate = { [weak self] handler, step, state in
            delegate.progressDidUpdate(handler, step: step, state: state)
            self?.handleProgressDidUpdate(handler: handler, step: step, state: state)
        }

        let handler = stepHandlerFactory(request, proxyDelegate)
        currentHandler = handler
        handler.start()

        return {
            let _ = proxyDelegate // capture proxyDelegate strongly
            handler.cancel()
        }
    }

    private func handleProgressDidUpdate(handler _: StepProgressHandling, step _: Int, state: StepProgressState) {
        switch state {
        case .initial, .running:
            break
        case .cancelled, .finished:
            currentHandler = nil
        }
    }
}

private class ProxyStepProgressDelegate: StepProgressDelegate {
    var onProgressDidUpdate: (StepProgressHandling, Int, StepProgressState) -> Void = { _, _, _ in }
    func progressDidUpdate(_ handler: StepProgressHandling, step: Int, state: StepProgressState) {
        onProgressDidUpdate(handler, step, state)
    }
}
