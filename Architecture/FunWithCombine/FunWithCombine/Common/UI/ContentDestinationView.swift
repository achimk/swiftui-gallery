import SwiftUI

struct ContentDestinationView<Content, Destination, Label>: View where Content: View, Destination: View, Label: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let destination: () -> Destination
    @ViewBuilder let label: () -> Label

    var body: some View {
        content()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: {
                        destination()
                    }, label: {
                        label()
                    })
                }
            }
    }
}
