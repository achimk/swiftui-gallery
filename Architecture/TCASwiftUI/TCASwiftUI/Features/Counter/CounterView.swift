import SwiftUI

struct CounterView: View {
    @ObservedObject var store: ViewStore<CounterState, CounterAction>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 44.0) {
                
                Spacer(minLength: 120.0)
                
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                
                Text("Counter: \(store.state.value)")
                
                HStack {
                    
                    Button("+") {
                        store.send(CounterAction.increment)
                    }
                    
                    Button("-") {
                        store.send(CounterAction.decrement)
                    }
                }
            }
        }
    }
}

#Preview {
    CounterView(store: RootStore(initialState: CounterState(), reducer: counterReducer(into:action:)).toViewStore())
}
