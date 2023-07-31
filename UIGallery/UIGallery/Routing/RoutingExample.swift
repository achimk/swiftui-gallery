import Combine
import Foundation
import SwiftUI

// Namespace
enum RoutingExample {}

extension RoutingExample {
    enum Destination: Hashable, Codable {
        case start
        case count(Int)
        case finish
    }
}

extension RoutingExample {
    class Coordinator: ObservableObject {
        var componentsDescription: String {
            "No components!"
        }

        func gotoInitial() {}
        func gotoStart() {}
        func gotoNext(_: Int) {}
        func gotoFinish() {}
        func gotoPrevious() {}
    }

    @available(iOS 16.0, *)
    class NavigationPathCoordinator: Coordinator {
        @Published var path = NavigationPath()

        override var componentsDescription: String {
            "NavigationPath count: \(path.count)"
        }

        override func gotoInitial() {
            path.removeLast(path.count)
        }

        override func gotoStart() {
            path.append(Destination.start)
        }

        override func gotoNext(_ value: Int) {
            path.append(Destination.count(value))
        }

        override func gotoFinish() {
            path.append(Destination.finish)
        }

        override func gotoPrevious() {
            path.removeLast()
        }
    }

    class DestinationCoordinator: Coordinator {
        @Published var path: [Destination] = [] {
            didSet {
                print("=> path updated:\n", path)
            }
        }

        override var componentsDescription: String {
            "Destination count: \(path.count)"
        }

        override func gotoInitial() {
            path.removeLast(path.count)
        }

        override func gotoStart() {
            path.append(Destination.start)
        }

        override func gotoNext(_ value: Int) {
            path.append(Destination.count(value))
        }

        override func gotoFinish() {
            path.append(Destination.finish)
        }

        override func gotoPrevious() {
            path.removeLast()
        }

        func asBinding() -> Binding<Destination?> {
            Binding(get: { self.path.last }, set: { _ in })
        }
    }
}

extension RoutingExample {
    @available(iOS 16.0, *)
    struct PathNavigationView: View {
        @ObservedObject var coordinator = NavigationPathCoordinator()
        var body: some View {
            NavigationStack(path: $coordinator.path) {
                MainView()
                    .navigationDestination(for: Destination.self) { destination in
                        ViewFactory.viewForDestination(destination)
                    }
            }
            .environmentObject(coordinator as Coordinator)
        }
    }

    @available(iOS 16.0, *)
    struct DestinationNavigationStackView: View {
        @ObservedObject var coordinator = DestinationCoordinator()

        init(_ destinations: [Destination] = []) {
            coordinator.path = destinations
        }

        var body: some View {
            NavigationStack(path: $coordinator.path) {
                MainView()
                    .navigationDestination(for: Destination.self) { destination in
                        ViewFactory.viewForDestination(destination)
                    }
            }
            .environmentObject(coordinator as Coordinator)
        }
    }

    struct DestinationView: View {
        enum Page {
            case first
            case second
            case third
        }

        @ObservedObject var coordinator = DestinationCoordinator()
        @State var pageA = false
        @State var pageB = false
        @State var pageC = false
        @State var page: Page?

        var body: some View {
            makeStackPages()
        }

        private func makeStackPages() -> some View {
            NavigationView {
                VStack {
                    Text("Countdown")
                    Button("Start") {
                        pageA = false
                        pageB = false
                        pageC = true
                    }
                }
                .presentDestination(for: $pageC) {
                    VStack {
                        Text("C")
                        Button("Push B") {
                            pageB = true
                        }
                    }
                    .presentDestination(for: $pageB) {
                        VStack {
                            Text("B")
                            Button("Push A") {
                                pageA = true
                            }
                        }
                        .presentDestination(for: $pageA) {
                            VStack {
                                Text("A")
                                Button("Reset") {
                                    pageC = false
                                    // Reset below properties are causing bug:
                                    // pageB = false
                                    // pageA = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    struct MainView: View {
        @EnvironmentObject var coordinator: Coordinator
        var body: some View {
            VStack(spacing: 44) {
                DescriptionView()

                Text("Counter example")

                Button("Start") {
                    coordinator.gotoStart()
                }
            }
        }
    }

    struct StartView: View {
        @EnvironmentObject var coordinator: Coordinator
        var body: some View {
            VStack(spacing: 44) {
                DescriptionView()

                Text("Start counting...")

                Button("Next") {
                    coordinator.gotoNext(1)
                }
            }
        }
    }

    struct CountView: View {
        @EnvironmentObject var coordinator: Coordinator
        let value: Int
        var body: some View {
            VStack(spacing: 44) {
                DescriptionView()

                Text("Count: \(value)")

                Button("Next") {
                    coordinator.gotoNext(value + 1)
                }

                Button("Back") {
                    coordinator.gotoPrevious()
                }

                Button("Reset") {
                    coordinator.gotoInitial()
                }

                Button("Finish") {
                    coordinator.gotoFinish()
                }
            }
        }
    }

    struct FinishView: View {
        @EnvironmentObject var coordinator: Coordinator
        var body: some View {
            VStack(spacing: 44) {
                DescriptionView()

                Text("Finish!")

                Button("Reset") {
                    coordinator.gotoInitial()
                }
            }
        }
    }

    struct DescriptionView: View {
        @EnvironmentObject var coordinator: Coordinator
        var body: some View {
            VStack {
                Text(coordinator.componentsDescription)
            }
        }
    }
}

extension RoutingExample {
    enum ViewFactory {
        @ViewBuilder
        static func viewForDestination(_ destination: Destination) -> some View {
            switch destination {
            case .start:
                StartView()
            case let .count(value):
                CountView(value: value)
            case .finish:
                FinishView()
            }
        }
    }
}

struct NavigationStackModifier<Item: Hashable, Destination: View>: ViewModifier {
    let item: Item
    let selected: Binding<Item?>
    let destination: (Item) -> Destination

    func body(content: Content) -> some View {
        content.background(NavigationLink(isActive: selected.isPresent(with: { $0 == item })) {
            if let item = selected.wrappedValue {
                destination(item)
            } else {
                EmptyView()
            }
        } label: {
            EmptyView()
        })
    }
}

extension View {
    func navigationDestination<Item: Hashable>(
        for item: Item,
        selected: Binding<Item?>,
        @ViewBuilder destination: @escaping (Item) -> some View
    ) -> some View {
        modifier(NavigationStackModifier(item: item, selected: selected, destination: destination))
    }
}

struct PresentDestinationModifier<Destination: View>: ViewModifier {
    let isPresent: Binding<Bool>
    let destination: () -> Destination

    func body(content: Content) -> some View {
        content.background(NavigationLink(isActive: isPresent) {
            destination()
        } label: {
            EmptyView()
        })
    }
}

extension View {
    func presentDestination(
        for isPresent: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> some View
    ) -> some View {
        modifier(PresentDestinationModifier(isPresent: isPresent, destination: destination))
    }
}
