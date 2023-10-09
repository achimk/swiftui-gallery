import SwiftUI

struct RouterWithNavigationLink: View {
    @ObservedObject var coordinator = Coordinator(destination: .pageA)
    
    var body: some View {
        NavigationRouter(path: $coordinator.path)
            .environmentObject(coordinator)
    }
    
    // MARK: Coordinator
    
    class Coordinator: ObservableObject {
        @Published var path: [Destination] = []
        
        init(destination: Destination) {
            path.append(destination)
        }
        
        func push(_ destination: Destination) {
            path.append(destination)
        }
        
        func pushAll() {
            path.append(contentsOf: [.pageA, .pageB, .pageC, .pageD])
        }
        
        func pop() {
            if path.count > 1 {
                path.removeLast()
            }
        }
        
        func reset() {
            path.removeLast(path.count - 1)
        }
        
        func pathDescription() -> String {
            path.map { $0.toStringIdentifier() }.joined(separator: " -> ")
        }
    }
    
    struct CoordinatorView: View {
        @EnvironmentObject var coordinator: Coordinator
        let title: String
        
        var body: some View {
            VStack(spacing: 44) {
                Text(title)
                Text(coordinator.pathDescription())
                
                Button("Push A") { coordinator.push(.pageA) }
                Button("Push B") { coordinator.push(.pageB) }
                Button("Push C") { coordinator.push(.pageC) }
                Button("Push D") { coordinator.push(.pageD) }
                Button("Push All") { coordinator.pushAll() }
                
                Button("Pop") { coordinator.pop() }
                Button("Reset") { coordinator.reset() }
                
            }
            .padding()
        }
    }
    
    // MARK: Model
    
    struct NavigationRouter: View {
        @EnvironmentObject var coordinator: Coordinator
        @Binding var path: [Destination]
        
        init(path: Binding<[Destination]>) {
            self._path = path
        }
        
        var body: some View {
            path.map { AnyView(Destination.make(for: $0)) }
                .enumerated()
                .reversed()
                .reduce(AnyView(EmptyView())) { childView, content in
                    let (offset, parentView) = content
                    
                    return AnyView(
                        RouteNode(
                            path: $path,
                            childContent: childView,
                            content: parentView,
                            index: offset
                        )
                        .environmentObject(coordinator)
                    )
                }
        }
    }
    
    struct RouteNode: View {
        @Binding var path: [Destination]
        let childContent: AnyView
        let content: AnyView
        let index: Int
        
        var isNextActive: Binding<Bool> {
            Binding(get: {
                $path.wrappedValue.count > index + 1
            }, set: { isActive in
                // Works only on POP and noot working when:
                // - pop multiple screens
                // - push multiple screens
//                if !isActive {
//                    $path.wrappedValue.removeLast($path.wrappedValue.count - index - 1)
//                }
            })
        }
        
        var body: some View {
            content.background(
                NavigationLink(
                    isActive: isNextActive,
                    destination: { childContent },
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }

    enum Destination: Hashable {
        case pageA
        case pageB
        case pageC
        case pageD
        
        func toStringIdentifier() -> String {
            switch self {
            case .pageA: return "A"
            case .pageB: return "B"
            case .pageC: return "C"
            case .pageD: return "D"
            }
        }
        
        @ViewBuilder
        static func make(for destination: Destination) -> some View {
            switch destination {
            case .pageA:
                CoordinatorView(title: "Page A")
            case .pageB:
                CoordinatorView(title: "Page B")
            case .pageC:
                CoordinatorView(title: "Page C")
            case .pageD:
                CoordinatorView(title: "Page D")
            }
        }
    }
}

#Preview {
    NavigationView {
        RouterWithNavigationLink()
    }
}
