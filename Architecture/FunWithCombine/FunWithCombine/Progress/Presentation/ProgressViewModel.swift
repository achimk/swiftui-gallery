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
    private let requestProvider: () -> ProgressRequest
    private(set) var viewState = ProgressViewState()
    private var operation: ProgressOperation?

    init(requestProvider: @escaping () -> ProgressRequest) {
        self.requestProvider = requestProvider
    }

    deinit {
        cancel()
    }

    func start() {
        guard canStart(operation) else {
            return
        }

        let request = requestProvider()

        operation = ProgressOperation(
            numberOfSteps: request.numberOfSteps,
            stepDuration: request.stepDuration
        )

        operation?.onUpdate = { [weak self] currentStep, state in
            self?.operationDidUpdate(
                currentStep: currentStep,
                operationState: state,
                stepDuration: request.stepDuration
            )
        }

        operation?.start()
    }

    func cancel() {
        operation?.cancel()
    }

    private func canStart(_ operation: ProgressOperation?) -> Bool {
        guard let operation else {
            return true
        }

        switch operation.state {
        case .cancelled, .finished:
            return true
        default:
            return false
        }
    }

    private func operationDidUpdate(
        currentStep: Int,
        operationState: ProgressOperation.State,
        stepDuration: TimeInterval
    ) {
        viewState.step = currentStep
        viewState.stepDuration = stepDuration
        viewState.stateName = operationStateName(operationState)
        viewState.canStart = operationState != .running
        viewState.canCancel = operationState == .running
    }

    private func operationStateName(_ state: ProgressOperation.State) -> String {
        switch state {
        case .initial: return "Initial"
        case .running: return "Running"
        case .cancelled: return "Cancelled"
        case .finished: return "Finished"
        }
    }
}
