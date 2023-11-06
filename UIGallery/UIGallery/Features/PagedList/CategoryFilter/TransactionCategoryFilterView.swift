import SwiftUI

struct TransactionCategoryFilterView: View {
    @ObservedObject var viewModel: TransactionCategoryFilterViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                makeContent()
            }
        }
        .listStyle(.plain)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }

    @MainActor
    private func makeContent() -> some View {
        VStack {
            ForEach(viewModel.availableCategories) { category in
                TransactionRowView(title: category.id.title, color: category.id.color)
                    .onTapGesture {
                        category.onSelect()
                    }
            }
        }
    }
}

// struct TransactionCategoryFilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        TransactionCategoryFilterView()
//    }
// }
