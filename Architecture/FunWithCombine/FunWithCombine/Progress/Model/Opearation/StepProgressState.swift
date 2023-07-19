import Foundation

@frozen
enum StepProgressState: Equatable {
    case initial
    case running
    case cancelled
    case finished
}
