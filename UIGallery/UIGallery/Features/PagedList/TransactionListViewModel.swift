import Combine
import Foundation

final class TransactionListViewModel: ObservableObject {
    private let loader: PageLoader<TransactionQuery, [Transaction]>
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var activity: ActivityState = .initial
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var hasPageAvailable: Bool = false
    
    init(loader: PageLoader<TransactionQuery, [Transaction]>) {
        self.loader = loader
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
        case .available(let offset):
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
            self?.handlePageUpdate(state)
        }.store(in: &cancellables)
    }
    
    private func handlePageUpdate(_ state: PageState<[Transaction]>) {
        guard let request = state.request else {
            return
        }
        
        switch request {
        case .load:
            hasPageAvailable = false
            activity = state.loadState.toActivityState()
            state.loadState.ifSuccess { result in
                transactions = result.data
                hasPageAvailable = true
            }
        case .loadMore:
            activity = state.loadState.toActivityState()
            state.loadState.ifSuccess { result in
                transactions = transactions + result.data
                hasPageAvailable = !result.nextOffset.isCompleted
            }
            state.loadState.ifFailure { _ in
                hasPageAvailable = false
            }
        }
    }
}

extension TransactionListViewModel {
    
    static func makeStub() -> TransactionListViewModel {
        TransactionListViewModel(
            loader: .init { query in
                let numberOfItems: UInt = 4
                let nextOffset = query.offset + numberOfItems
                let repository = StubTransactionRepository()
                repository.delayInSeconds = 3
                repository.transactionGenerator.items = Int(numberOfItems)
                repository.transactionGenerator.offset = Int(query.offset)
                let transactions = try await repository.findAll(for: query)
                return .init(data: transactions, nextOffset: .available(offset: nextOffset))
            }
        )
    }
}
