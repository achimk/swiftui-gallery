import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionListViewModel

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ScrollView {
                    makeContent(with: proxy.size)
                }
                .refreshable {
                    await viewModel.refreshRequested()
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.viewAppeared()
        }
    }

    @ViewBuilder
    private func makeContent(with size: CGSize) -> some View {
        if viewModel.activity == .loading, viewModel.transactions.isEmpty {
            makeContentLoading()
                .frame(width: size.width, height: size.height)
        } else if viewModel.activity != .loading, viewModel.transactions.isEmpty {
            makeContentEmpty()
                .frame(width: size.width, height: size.height)
        } else {
            makeContentList()
                .frame(width: size.width)
        }
    }

    @ViewBuilder
    private func makeContentEmpty() -> some View {
        VStack(alignment: .center) {
            Spacer()
            Text("No transactions!")
            Spacer()
        }
    }

    @ViewBuilder
    private func makeContentLoading() -> some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Loading...")
            SwiftUI.ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }

    @ViewBuilder
    private func makeContentList() -> some View {
        LazyVStack {
            ForEach(viewModel.transactions) { transaction in
                TransactionItemView(transaction: transaction)
            }

            if viewModel.hasPageAvailable {
                TransactionLoadMoreView(onLoadMore: viewModel.pageLoadRequested)
            }
        }
        .padding(.horizontal, 24.0)
    }
}

struct TransactionItemView: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .center) {
            ZStack {
                Circle()
                    .fill(.radialGradient(
                        colors: [transaction.category.color, Color.white],
                        center: .center,
                        startRadius: 0.0,
                        endRadius: 20.0
                    ))
                    .frame(width: 43.0)
                    .padding(.top, 2)

                Circle()
                    .fill(transaction.category.color)
                    .frame(width: 30.0)
            }
            Text(transaction.name)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 24.0)
    }
}

struct TransactionLoadMoreView: View {
    let onLoadMore: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            SwiftUI.ProgressView()
                .progressViewStyle(.circular)
        }
        .padding(24.0)
        .onAppear {
            onLoadMore()
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView(
            viewModel: .makeStub()
        )
    }
}
