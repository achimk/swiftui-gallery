import Combine
import Foundation

final class TransactionListViewModel: ObservableObject {
    private let loader: PageLoader<TransactionQuery, [Transaction]>
    private let listPublisher: PageListPublisher<Transaction>
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var activity: PagingActivityStatus = .initial
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var hasPageAvailable: Bool = false

    init(operation: @escaping (TransactionQuery, UInt) async throws -> PageResult<[Transaction]>) {
        let loader = PageLoader(operation)
        self.loader = loader
        listPublisher = PageListPublisher(pagePublisher: loader.eraseToAnyPublisher())
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
        TransactionQuery(category: nil)
    }

    private func makeNextQuery() -> TransactionQuery? {
        switch loader.pagination.currentOffset {
        case .available:
            return TransactionQuery(
                category: nil
            )
        case .completed:
            return nil
        }
    }

    private func setupBindings() {
        loader.sink { [weak self] pageState in
            self?.printState(of: pageState)
        }.store(in: &cancellables)

        let loaderPublisher = loader
            .prepend(.initial)
            .eraseToAnyPublisher()

        let itemsPublisher = listPublisher
            .prepend([])
            .eraseToAnyPublisher()

        Publishers.CombineLatest(loaderPublisher, itemsPublisher)
            .sink { [weak self] pageState, items in
                self?.handleUpdate(
                    request: pageState.pageRequest,
                    status: pageState.toPagingActivityStatus(),
                    items: items
                )
            }.store(in: &cancellables)
    }

    private func printState(of pageState: PagingState<[Transaction]>) {
        print("[State]")
        print("-> request:", pageState.pageRequest ?? "-")
        print("-> offset:", loader.pagination.currentOffset)
        print("-> status:", pageState.toPagingActivityStatus())
        print("-> items:", pageState.data?.count ?? "-")
    }

    private func handleUpdate(request: PageRequest?, status: PagingActivityStatus, items: [Transaction]) {
        handleUpdatePageAvailability(request: request, status: status)
        transactions = items
        activity = status
    }

    private func handleUpdatePageAvailability(request: PageRequest?, status: PagingActivityStatus) {
        guard let request else {
            hasPageAvailable = false
            return
        }

        switch request {
        case .load:
            hasPageAvailable = false
            if status == .success {
                hasPageAvailable = true
            }
        case .loadMore:
            switch status {
            case .success:
                hasPageAvailable = loader.pagination.currentOffset.isAvailable
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
