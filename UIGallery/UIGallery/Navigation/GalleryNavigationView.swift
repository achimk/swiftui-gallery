import SwiftUI

struct GalleryNavigationView: View {
    
    struct Box: Identifiable {
        var value: Int
        var id: Int { return value }
    }
    
    enum Route: Equatable {
        case listDetailFlow
        case cardDetailFlow
        case modalSheet
        case bottomSheet
        case alert
        case confirmationDialog
        case associatedAlert(Int)
        case associatedDialog(Int)
        case associatedSheet(Int)
    }
    
    @State private var route: Route? = nil
    
    var body: some View {
        List {
            Section {
                makeListDetailFlow()
                makeCardDetailFlow()
                makeModalSheetFlow()
                makeBottomSheetFlow()
                makeConfirmationDialogFlow()
                makeAlertFlow()
            }
            
            Section {
                makeAssociatedAlertFlow()
                makeAssociatedDialogFlow()
                makeAssociatedSheetFlow()
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
        .sheet(isPresented: $route.isPresent { $0 == .listDetailFlow }) {
            ColorListView(colors: ColorModel.generate(count: 100))
        }
    }
    
    private func makeCardDetailFlow() -> some View {
        Button {
            route = .cardDetailFlow
        } label: {
            Text("Card - Detail flow")
        }
        .sheet(isPresented: $route.isPresent { $0 == .cardDetailFlow }) {
            ArticleCardListView(articles: ArticleModel.generate(count: 10))
        }
    }
    
    private func makeModalSheetFlow() -> some View {
        Button {
            route = .modalSheet
        } label: {
            Text("Modal sheet")
        }
        .sheet(isPresented: $route.isPresent { $0 == .modalSheet }) {
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
            .sheet(isPresented: $route.isPresent { $0 == .bottomSheet }) {
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
        .alert(isPresented: $route.isPresent { $0 == .alert }) {
            Alert(
                title: Text("Title"),
                message: Text("Message")
            )
        }
    }
    
    private func makeConfirmationDialogFlow() -> some View {
        Button {
            route = .confirmationDialog
        } label: {
            Text("Confirmation dialog")
        }
        .confirmationDialog(
            "Title",
            isPresented: $route.isPresent { $0 == .confirmationDialog },
            actions: {
                Button("Option 1") { }
                Button("Option 2") { }
                Button("Option 3") { }
                Button("Cancel", role: .cancel) { }
            },
            message: {
                Text("Message")
            })
    }
    
    private func makeAssociatedAlertFlow() -> some View {
        Button {
            route = .associatedAlert((1...10).randomElement() ?? 0)
        } label: {
            Text("Associated value dialog")
        }
        .alert(
            title: {
                Text("Title: \($0)")
            },
            presenting: $route.isPresent {
                if case .associatedAlert(let value) = $0 {
                    return value
                } else {
                    return nil
                }
            },
            actions: { _ in
                Button("Ok") { }
                Button("Cancel", role: .cancel) { }
            },
            message: {
                Text("Message: \($0)")
            })
    }
    
    private func makeAssociatedDialogFlow() -> some View {
        Button {
            route = .associatedDialog((1...10).randomElement() ?? 0)
        } label: {
            Text("Confirmation dialog")
        }
        .confirmationDialog(
            title: {
                Text("Title: \($0)")
            },
            presenting: $route.isPresent(with: {
                if case .associatedDialog(let value) = $0 {
                    return value
                } else {
                    return nil
                }
            }),
            actions: { _ in
                Button("Option 1") { }
                Button("Option 2") { }
                Button("Option 3") { }
                Button("Cancel", role: .cancel) { }
            },
            message: {
                Text("Message: \($0)")
            })
    }
    
    private func makeAssociatedSheetFlow() -> some View {
        Button {
            route = .associatedSheet((1...10).randomElement() ?? 0)
        } label: {
            Text("Confirmation dialog")
        }
        .sheet(
            item: $route.isPresent {
                if case .associatedSheet(let value) = $0 {
                    return Box(value: value)
                } else {
                    return nil
                }
            },
            content: { box in
                Text("Message: \(box.value)")
            })
    }
}

struct GalleryNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryNavigationView()
    }
}
