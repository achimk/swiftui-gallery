import SwiftUI

@main
struct UIGalleryApp: App {
    
    init() {
        NavigationAppearance.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            GalleryRootView()
        }
    }
}
