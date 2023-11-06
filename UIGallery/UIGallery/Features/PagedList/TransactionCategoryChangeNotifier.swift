import Combine
import Foundation

enum TransactionCategoryChangeEvent {
    case categoryChangeScheduled(UUID, TransactionCategory)
    case categoryChangeSucceeded(UUID, TransactionCategory)
    case categoryChangeFailed(UUID, TransactionCategory)
}

struct TransactionCategoryChangeState: Equatable {
    var isAvailable: Bool
    var pending: [UUID: TransactionCategory]

    static let unavailable = TransactionCategoryChangeState(
        isAvailable: false,
        pending: [:]
    )
}

final class TransactionCategoryChangeNotifier {
    private let repository: TransactionRepository
    private let isEnabledPublisher: AnyPublisher<Bool, Never>
    private let stateSubject = CurrentValueSubject<TransactionCategoryChangeState, Never>(.unavailable)
    private let eventSubject = PassthroughSubject<TransactionCategoryChangeEvent, Never>()
    private var cancellables = Set<AnyCancellable>()

    var state: TransactionCategoryChangeState {
        stateSubject.value
    }

    init(
        repository: TransactionRepository,
        isEnabledPublisher: AnyPublisher<Bool, Never>
    ) {
        self.repository = repository
        self.isEnabledPublisher = isEnabledPublisher
        setupBindings()
    }

    // MARK: Input

    func change(category: TransactionCategory, for transactionId: UUID) {
        Task { @MainActor in
            await handleChange(category: category, for: transactionId)
        }
    }

    // MARK: Output

    var statePublisher: AnyPublisher<TransactionCategoryChangeState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var eventPublisher: AnyPublisher<TransactionCategoryChangeEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}

extension TransactionCategoryChangeNotifier {
    @MainActor
    private func handleChange(category: TransactionCategory, for transactionId: UUID) async {
        guard
            state.isAvailable,
            !state.pending.keys.contains(transactionId)
        else {
            return
        }

        do {
            updateState {
                $0.pending[transactionId] = category
            }
            notify(with: .categoryChangeScheduled(transactionId, category))
            try await repository.update(category: category, for: transactionId)
            updateState {
                $0.pending[transactionId] = nil
            }
            notify(with: .categoryChangeSucceeded(transactionId, category))
        } catch {
            updateState {
                $0.pending[transactionId] = nil
            }
            notify(with: .categoryChangeSucceeded(transactionId, category))
        }
    }

    private func updateState(_ builder: (inout TransactionCategoryChangeState) -> Void) {
        var state = stateSubject.value
        builder(&state)
        stateSubject.value = state
    }

    private func notify(with event: TransactionCategoryChangeEvent) {
        eventSubject.send(event)
    }
}

extension TransactionCategoryChangeNotifier {
    private func setupBindings() {
        isEnabledPublisher
            .prepend(false)
            .removeDuplicates()
            .sink { [weak self] isAvailable in
                self?.updateState {
                    $0.isAvailable = isAvailable
                }
            }.store(in: &cancellables)
    }
}
