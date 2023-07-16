import Foundation

struct ProgressRequest {
    let numberOfSteps: Int
    let stepDuration: TimeInterval

    init(numberOfSteps: Int, stepDuration: TimeInterval) {
        self.numberOfSteps = max(0, numberOfSteps)
        self.stepDuration = max(0.0, stepDuration)
    }
}
