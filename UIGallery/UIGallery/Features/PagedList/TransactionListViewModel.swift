import Combine
import Foundation

final class TransactionListViewModel: ObservableObject {
    private let loader: XPageDataLoader<TransactionQuery, [Transaction]>
    private let listCollection: XPageDataMutableListCollection<Transaction>
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var activity: ActivityState = .initial
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var hasPageAvailable: Bool = false

    init(operation: @escaping (TransactionQuery, UInt) async throws -> XPageResult<[Transaction]>) {
        let loader = XPageDataLoader(operation)
        self.loader = loader
        listCollection = XPageDataMutableListCollection(
            pagination: loader.asPagination(),
            pagePublisher: loader.eraseToAnyPublisher()
        )
        setupBindings()
    }

    func viewAppeared() {
        loader.load(with: makeInitialQuery())
    }

    @MainActor
    func refreshRequested() async {
        await loader.load(with: makeInitialQuery())
    }

    func pageLoadRequested() {
        if let query = makeNextQuery() {
            loader.loadMore(with: query)
        }
    }

    func remove(at index: Int) {
        listCollection.remove(at: index)
    }

    private func makeInitialQuery() -> TransactionQuery {
        TransactionQuery(category: nil)
    }

    private func makeNextQuery() -> TransactionQuery? {
        switch loader.state.offset {
        case .available:
            return TransactionQuery(
                category: nil
            )
        case .completed:
            return nil
        }
    }

    private func setupBindings() {
        loader.sink { [weak self] state in
            self?.handleLoaderUpdate(state)
        }.store(in: &cancellables)
        listCollection.sink { [weak self] state in
            self?.handlePageUpdate(state)
        }.store(in: &cancellables)
    }

    private func handleLoaderUpdate(_: XPagingState<[Transaction]>) {
//        print("[Loader State]")
//        print("-> request:", state.request)
//        print("-> offset:", state.offset)
//        print("-> status:", state.status)
//        print("-> items:", state.data.count)
    }

    private func handlePageUpdate(_ state: XPagingState<[Transaction]>) {
        print("[Collection State]")
        print("-> request:", state.request)
        print("-> offset:", state.offset)
        print("-> status:", state.status)
        print("-> items:", state.data.count)
        print("-> offset:", loader.asPagination().currentOffset)

        activity = state.status.toActivityState()
        transactions = state.data

        switch state.request {
        case .load:
            hasPageAvailable = false
            if state.status == .success {
                hasPageAvailable = true
            }
        case .loadMore:
            switch state.status {
            case .success:
                hasPageAvailable = state.offset == .available
            case .failure:
                hasPageAvailable = false
            default:
                break
            }
        }
    }
}

extension TransactionListViewModel {
    static func makeStub() -> TransactionListViewModel {
        TransactionListViewModel(
            operation: { query, offset in
                let numberOfItems: UInt = 4
                let nextOffset = offset + numberOfItems
                let repository = StubTransactionRepository()
                repository.delayInSeconds = 3
                repository.transactionGenerator.items = Int(numberOfItems)
                repository.transactionGenerator.offset = Int(offset)
                let transactions = try await repository.findAll(for: query)
                return .init(data: transactions, offset: .available(offset: nextOffset))
            }
        )
    }
}
