import Combine
import Foundation

class CounterViewState: ObservableObject {
    @Published var value: Int = 0
}

class MainViewState {
    let counter = CounterViewState()
}

class OtherViewState {
    let viewState: MainViewState
    var counter: CounterViewState {
        viewState.counter
    }

    init(viewState: MainViewState) {
        self.viewState = viewState
    }
}

let viewState = MainViewState()
let otherState = OtherViewState(viewState: viewState)

otherState.counter.$value.sink { value in
    print(value)
}

viewState.counter.value = 1
