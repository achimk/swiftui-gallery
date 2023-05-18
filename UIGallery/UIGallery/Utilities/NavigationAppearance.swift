import UIKit

struct NavigationAppearance {
    
    // There isn't possibility to change appearance of
    // navigation stack with SiwftUI. Instead old API
    // is used to setup proper layout.
    static func setup() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemPink,
            .font: UIFont(name: "ArialRoundedMTBold", size: 35)!]
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemPink,
            .font: UIFont(name: "ArialRoundedMTBold", size: 20)!]
//        navigationBarAppearance.setBackIndicatorImage(
//            UIImage(systemName: "arrow.turn.up.left"),
//            transitionMaskImage: UIImage(systemName: "arrow.turn.up.left"))
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        
    }
}
