import Combine
import Foundation

final class TransactionListViewModel: ObservableObject {
    private let loader: XPageDataLoader<TransactionQuery, [Transaction]>
    private let listCollection: XPageDataListCollection<Transaction>
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var activity: ActivityState = .initial
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var hasPageAvailable: Bool = false

    init(operation: @escaping (TransactionQuery, UInt) async throws -> XPageResult<[Transaction]>) {
        let loader = XPageDataLoader(operation)
        self.loader = loader
        listCollection = XPageDataListCollection(pagePublisher: loader.eraseToAnyPublisher())
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

    private func makeInitialQuery() -> TransactionQuery {
        TransactionQuery(offset: 0, category: nil)
    }

    private func makeNextQuery() -> TransactionQuery? {
        switch loader.state.offset {
        case let .available(offset):
            return TransactionQuery(
                offset: offset,
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
//        print("[Collection State]")
//        print("-> request:", state.request)
//        print("-> offset:", state.offset)
//        print("-> status:", state.status)
//        print("-> items:", state.data.count)

        switch state.request {
        case .load:
            hasPageAvailable = false
            activity = state.status.toActivityState()
            transactions = state.data
            if state.status == .success {
                hasPageAvailable = true
            }

        case .loadMore:
            activity = state.status.toActivityState()
            switch state.status {
            case .success:
                transactions = state.data
                hasPageAvailable = state.offset.isAvailable
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
            operation: { query, _ in
                let numberOfItems: UInt = 4
                let nextOffset = query.offset + numberOfItems
                let repository = StubTransactionRepository()
                repository.delayInSeconds = 3
                repository.transactionGenerator.items = Int(numberOfItems)
                repository.transactionGenerator.offset = Int(query.offset)
                let transactions = try await repository.findAll(for: query)
                return .init(data: transactions, offset: .available(offset: nextOffset))
            }
        )
    }
}
