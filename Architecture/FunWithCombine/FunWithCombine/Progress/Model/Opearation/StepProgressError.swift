import Foundation

enum StepProgressError: Int, Error {
    case alreadyRunning
    case cancelInvoked
}
