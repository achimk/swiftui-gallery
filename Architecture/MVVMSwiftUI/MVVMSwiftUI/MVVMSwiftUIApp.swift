import SwiftUI

@main
struct MVVMSwiftUIApp: App {
    private let coordinator = UserCoordinator()

    init() {
        ApplicationDependenciesAssembly.assemble(with: .shared)
    }

    var body: some Scene {
        WindowGroup {
            UserCoordinatorView(coordinator: coordinator)
        }
    }
}
