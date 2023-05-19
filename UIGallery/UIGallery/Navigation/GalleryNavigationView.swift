import SwiftUI

struct GalleryNavigationView: View {
    
    enum Route: Int, Identifiable {
        var id: Int {
            return rawValue
        }
        
        case listDetailFlow
        case cardDetailFlow
        case modalSheet
        case bottomSheet
        case alert
        case confirmationDialog
    }
    
    @State private var route: Route? = nil
    
    var body: some View {
        List {
            Section {
                makeListDetailFlow()
                makeCardDetailFlow()
                makeModalSheetFlow()
                makeBottomSheetFlow()
                makeAlertFlow()
                makeConfirmationDialogFlow()
            }
        }
        .navigationTitle("Navigation")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func makeListDetailFlow() -> some View {
        Button {
            route = .listDetailFlow
        } label: {
            Text("List - Detail flow")
        }
        .sheet(unwrap: $route, condition: { $0 == .listDetailFlow }) { _ in
            ColorListView(colors: ColorModel.generate(count: 100))
        }
    }
    
    private func makeCardDetailFlow() -> some View {
        Button {
            route = .cardDetailFlow
        } label: {
            Text("Card - Detail flow")
        }
        .sheet(unwrap: $route, condition: { $0 == .cardDetailFlow }) { _ in
            ArticleCardListView(articles: ArticleModel.generate(count: 10))
        }
    }
    
    private func makeModalSheetFlow() -> some View {
        Button {
            route = .modalSheet
        } label: {
            Text("Modal sheet")
        }
        .sheet(unwrap: $route, condition: { $0 == .modalSheet }) { _ in
            ColorDetailView(
                colorModel: .constant(ColorModel.generate()),
                dismissContext: .modal)
        }
    }
    
    @ViewBuilder
    private func makeBottomSheetFlow() -> some View {
        if #available(iOS 16, *) {
            Button {
                route = .bottomSheet
            } label: {
                Text("Bottom sheet (iOS 16)")
            }
            .sheet(unwrap: $route, condition: { $0 == .bottomSheet }) { _ in
                ColorDetailView(
                    colorModel: .constant(ColorModel.generate()),
                    dismissContext: .bottomSheet
                )
                .presentationDetents([.medium, .large])
            }
        } else {
            makeModalSheetFlow()
        }
    }
    
    private func makeAlertFlow() -> some View {
        Button {
            route = .alert
        } label: {
            Text("Alert")
        }
        .alert(
            title: { _ in Text("Title") },
            unwrap: $route,
            condition: { $0 == .alert },
            actions: { _ in },
            message: { _ in Text("Message") })
    }
    
    private func makeConfirmationDialogFlow() -> some View {
        Button {
            route = .confirmationDialog
        } label: {
            Text("Confirmation dialog")
        }
        .confirmationDialog(
            title: { _ in Text("Title")},
            unwrap: $route,
            condition: { $0 == .confirmationDialog },
            actions: { _ in
                Button("Option 1") { }
                Button("Option 2") { }
                Button("Option 3") { }
                Button("Cancel", role: .cancel) { }
            },
            message: { _ in Text("Message") })
    }
}

struct GalleryNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryNavigationView()
    }
}
