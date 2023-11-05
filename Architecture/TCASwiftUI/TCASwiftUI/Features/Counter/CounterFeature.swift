import Foundation

struct CounterState: Equatable {
    var value: Int = 0
}

enum CounterAction: Action {
    case increment
    case decrement
}

func counterReducer(into state: inout CounterState, action: Action) {
    guard let action = action as? CounterAction else { return }
    switch action {
    case .increment:
        state.value += 1
    case .decrement:
        state.value -= 1
    }
}
