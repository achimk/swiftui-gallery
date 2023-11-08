import SwiftUI

struct HiddenListItems: View {
    @ObservedObject var viewModel: HiddenList.ViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                makeContentView(with: proxy.size)
            }
        }
    }

    @ViewBuilder
    private func makeContentView(with size: CGSize) -> some View {
        if viewModel.isEmpty {
            makeEmptyView()
                .frame(width: size.width, height: size.height)
        } else {
            makeListView()
        }
    }

    @ViewBuilder
    private func makeEmptyView() -> some View {
        VStack {
            Spacer()
            Text("No content!")
                .frame(maxWidth: .infinity)
                .font(.headline)
            Spacer()
        }
    }

    @ViewBuilder
    private func makeListView() -> some View {
        VStack {
            ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                if item.isHidden {
                    EmptyView()
                } else {
                    Text(item.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24.0)
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(Color.mint)
                        .onTapGesture {
                            viewModel.hide(at: index)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24.0)
    }
}

enum HiddenList {
    struct ViewData: Identifiable, Equatable {
        var id: UUID
        var title: String
        var isHidden: Bool
    }

    struct ViewDataBuilder {
        func build(count: Int) -> [ViewData] {
            (0 ..< count).map(makeViewData(at:))
        }

        private func makeViewData(at index: Int) -> ViewData {
            ViewData(
                id: UUID(),
                title: "title \(index)",
                isHidden: false
            )
        }
    }

    class ViewModel: ObservableObject {
        @Published private(set) var items: [ViewData] = []
        @Published private(set) var isEmpty: Bool = true

        init() {
            items = ViewDataBuilder().build(count: 10)
            setupIsEmpty()
        }

        func hide(at index: Int) {
            items[index].isHidden = true
            setupIsEmpty()
        }

        private func setupIsEmpty() {
            isEmpty = items.first(where: { $0.isHidden == false }) == nil
        }
    }
}

struct HiddenListItems_Previews: PreviewProvider {
    static var previews: some View {
        HiddenListItems(viewModel: HiddenList.ViewModel())
    }
}
