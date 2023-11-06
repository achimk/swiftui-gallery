import SwiftUI

struct NestedNavigationLink: View {
    @State var model = NavigationModel()

    var body: some View {
        PageA(model: model)
    }

    // MARK: Model

    class NavigationModel: ObservableObject {
        @Published var presentB = false {
            didSet { getState() }
        }

        @Published var presentC = false {
            didSet { getState() }
        }

        @Published var presentD = false {
            didSet { getState() }
        }

        @Published var state: String = "-"

        init() {
            getState()
        }

        func enableAll() {
            presentB = true
            presentC = true
            presentD = true
        }

        func reset() {
            presentB = false
            presentC = false
            presentD = false
        }

        func getState() {
            var allStates = ["A"]
            if presentB {
                allStates.append("B")
            } else {
                allStates.append("_")
            }

            if presentC {
                allStates.append("C")
            } else {
                allStates.append("_")
            }

            if presentD {
                allStates.append("D")
            } else {
                allStates.append("_")
            }

            state = allStates.joined(separator: " -> ")
        }
    }

    // MARK: Views

    struct ToggleView: View {
        let title: String
        @ObservedObject var model: NavigationModel

        var body: some View {
            VStack(spacing: 44) {
                Text(title)
                Button(model.state) { model.getState() }
                Toggle("Present B:", isOn: $model.presentB)
                Toggle("Present C:", isOn: $model.presentC)
                Toggle("Present D:", isOn: $model.presentD)
                Button("Enable all") { model.enableAll() }
                Button("Reset") { model.reset() }
            }
            .padding()
        }
    }

    struct PageA: View {
        @ObservedObject var model: NavigationModel

        var body: some View {
            ToggleView(title: "Page A", model: model)
                .background(
                    NavigationLink(
                        isActive: $model.presentB,
                        destination: { PageB(model: model) },
                        label: { EmptyView() }
                    )
                )
        }
    }

    struct PageB: View {
        @ObservedObject var model: NavigationModel

        var body: some View {
            ToggleView(title: "Page B", model: model)
                .background(
                    NavigationLink(
                        isActive: $model.presentC,
                        destination: { PageC(model: model) },
                        label: { EmptyView() }
                    )
                )
        }
    }

    struct PageC: View {
        @ObservedObject var model: NavigationModel

        var body: some View {
            ToggleView(title: "Page C", model: model)
                .background(
                    NavigationLink(
                        isActive: $model.presentD,
                        destination: { PageD(model: model) },
                        label: { EmptyView() }
                    )
                )
        }
    }

    struct PageD: View {
        @ObservedObject var model: NavigationModel

        var body: some View {
            ToggleView(title: "Page D", model: model)
        }
    }
}

struct NestedNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        NestedNavigationLink()
    }
}
