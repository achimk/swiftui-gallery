import Combine
import Foundation

class ProgressViewState: ObservableObject {
    @Published fileprivate(set) var step: Int = 0
    @Published fileprivate(set) var stepDuration: TimeInterval = 0.0
    @Published fileprivate(set) var stateName: String = "-"
    @Published fileprivate(set) var canStart = true
    @Published fileprivate(set) var canCancel = false
}

class ProgressViewModel {
    private let manager: StepProgressManager
    private let requestProvider: () -> StepProgressRequest
    private(set) var viewState = ProgressViewState()
    private var cancelToken: StepProgressCancelation?

    init(
        manager: StepProgressManager,
        requestProvider: @escaping () -> StepProgressRequest
    ) {
        self.manager = manager
        self.requestProvider = requestProvider
    }

    deinit {
        cancel()
    }

    func start() {
        guard canStart() else {
            return
        }
        cancel()
        renderEmpty()
        let request = requestProvider()
        renderRequested(request: request)
        do {
            cancelToken = try manager.schedule(with: request, delegate: self)
        } catch {
            renderEmpty()
        }
    }

    func cancel() {
        cancelToken?()
        cancelToken = nil
    }

    private func canStart() -> Bool {
        manager.canSchedule()
    }
}

extension ProgressViewModel: StepProgressDelegate {
    func progressDidUpdate(_: StepProgressHandling, step: Int, state: StepProgressState) {
        renderUpdated(step: step, state: state)
    }
}

extension ProgressViewModel {
    func renderEmpty() {
        viewState.step = 0
        viewState.stepDuration = 0.0
        viewState.stateName = "-"
        viewState.canStart = true
        viewState.canCancel = false
    }

    func renderRequested(request: StepProgressRequest) {
        viewState.step = 0
        viewState.stepDuration = request.stepDuration
        viewState.canStart = false
        viewState.canCancel = true
    }

    func renderUpdated(step: Int, state: StepProgressState) {
        viewState.step = step
        viewState.stateName = stepProgressStateName(from: state)
        viewState.canStart = !(state == .running)
        viewState.canCancel = state == .running
    }
}

private func stepProgressStateName(from state: StepProgressState) -> String {
    switch state {
    case .initial: return "Initial"
    case .running: return "Running"
    case .cancelled: return "Cancelled"
    case .finished: return "Finished"
    }
}
