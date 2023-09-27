//

import SwiftUI

enum PreviewTheme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"

    var id: String {
        rawValue
    }

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

extension View {
    func preview(_ theme: PreviewTheme) -> some View {
        preferredColorScheme(theme.colorScheme)
            .previewDisplayName(theme.rawValue)
    }
}

struct ForEachPreview<Content: View>: View {
    private let content: (PreviewTheme) -> Content

    init(@ViewBuilder content: @escaping (PreviewTheme) -> Content) {
        self.content = content
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = { _ in
            content()
        }
    }

    var body: some View {
        ForEach(PreviewTheme.allCases) { theme in
            content(theme)
                .preview(theme)
        }
    }
}

struct ForEachPreview_Previews: PreviewProvider {
    static var previews: some View {
        ForEachPreview { theme in
            Text("Applied theme: \(theme.rawValue)")
        }
    }
}
