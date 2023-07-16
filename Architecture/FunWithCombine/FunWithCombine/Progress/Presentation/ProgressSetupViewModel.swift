import Combine
import Foundation

class ProgressSetupViewState: ObservableObject {
    let numberOfStepsRange: ClosedRange<Float> = 1.0 ... 10.0
    let stepDurationRange: ClosedRange<TimeInterval> = 1.0 ... 10.0
    @Published var numberOfSteps: Float = 1.0
    @Published var stepDuration: TimeInterval = 1.0
}

class ProgressSetupViewModel {
    private(set) var viewState = ProgressSetupViewState()
}

extension ProgressSetupViewModel {
    func toProgressRequest() -> ProgressRequest {
        ProgressRequest(
            numberOfSteps: Int(viewState.numberOfSteps),
            stepDuration: viewState.stepDuration
        )
    }
}
