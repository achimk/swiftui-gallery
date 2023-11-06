import Combine
import Foundation

final class TransactionCategoryFilterViewModel: ObservableObject {
    private let notifier: TransactionCategoryFilterNotifier
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var availableCategories: [CategoryItem] = []

    init(notifier: TransactionCategoryFilterNotifier) {
        self.notifier = notifier
        setupBindings()
    }
}

extension TransactionCategoryFilterViewModel {
    private func setupBindings() {
        notifier.statePublisher.sink { [weak self] state in
            self?.handleStateUpdate(state)
        }.store(in: &cancellables)
    }

    private func handleStateUpdate(_ state: TransactionCategoryState) {
        let onSelect: (TransactionCategory) -> Void = { [notifier] in
            notifier.select(state.selectedCategory == $0 ? nil : $0)
        }
        availableCategories = state.availableCategories.map { category in
            CategoryItem(
                id: category,
                isSelected: category == state.selectedCategory,
                onSelect: { onSelect(category) }
            )
        }
    }
}

extension TransactionCategoryFilterViewModel {
    struct CategoryItem: Identifiable {
        var id: TransactionCategory
        var isSelected: Bool
        var onSelect: () -> Void
    }
}
