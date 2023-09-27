import SwiftUI

@main
struct MVVMSwiftUIApp: App {
    private let coordinator = UserCoordinator()

    init() {
        ApplicationDependenciesAssembly.assemble(with: .shared)
        print("locale preferred languages:", Locale.preferredLanguages)
    }

    var body: some Scene {
        WindowGroup {
            UserCoordinatorView(coordinator: coordinator)
        }
    }
}
