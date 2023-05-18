import SwiftUI

struct ColorModel: Identifiable {
    var id = UUID()
    var color: Color
    var title: String
    var description: String
}

extension ColorModel {
    
    static let availableColors: [Color] = [
        .cyan,
        .pink,
        .purple,
        .mint,
        .indigo,
        .orange
    ]
    
    static func generate(count: Int) -> [ColorModel] {
        (1...count).map { _ in
            generate()
        }
    }
    
    static func generate() -> ColorModel {
        let color = availableColors.randomElement() ?? .cyan
        return ColorModel(
            color: color,
            title: "\(color.description.capitalized)",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent gravida purus sit amet porta feugiat. Curabitur nunc nibh, commodo a arcu eget, consequat pellentesque purus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse aliquam diam libero, nec efficitur lacus porttitor in. Praesent rhoncus efficitur nibh, at molestie mauris sodales sed. Cras sollicitudin nisl at mauris mattis tristique eu suscipit velit. Aliquam hendrerit semper massa in ullamcorper. Nunc nibh lorem, congue venenatis urna in, malesuada consectetur diam. Donec tincidunt tincidunt velit, id vulputate sem interdum vel. Nam consectetur blandit nisl."
        )
    }
}

