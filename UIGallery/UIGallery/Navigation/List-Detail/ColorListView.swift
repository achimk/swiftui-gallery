import SwiftUI

struct ColorListView: View {
    var colors: [ColorModel]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(colors) { color in
                    NavigationLink {
                        ColorDetailView(colorModel: .constant(color))
                    } label: {
                        ColorRowView(
                            color: .constant(color.color),
                            text: .constant(color.title))
                    }
                    
                }
            }
            .listStyle(.plain)
            .navigationTitle("Colors")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ColorListView_Previews: PreviewProvider {
    static let colors = ColorModel.generate(count: 100)
    
    static var previews: some View {
        ColorListView(colors: colors)
    }
}
