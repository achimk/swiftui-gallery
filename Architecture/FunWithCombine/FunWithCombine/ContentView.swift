import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                // Tasks section
                Section {
                    NavigationLink("Plain operation") {
                        ProgressFactory.make()
                    }
                } header: {
                    Text("Tasks")
                }

                // Combine section
                Section {
                    NavigationLink("Buttons") {
                        EmptyView()
                    }
                    NavigationLink("TextFields") {
                        EmptyView()
                    }
                } header: {
                    Text("Combine")
                }
            }
            .navigationTitle("Examples")
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
