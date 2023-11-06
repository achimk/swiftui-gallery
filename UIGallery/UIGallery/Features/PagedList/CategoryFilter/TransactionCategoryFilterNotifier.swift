import Combine
import Foundation

struct TransactionCategoryState: Equatable {
    var isAvailable: Bool
    var selectedCategory: TransactionCategory?
    var availableCategories: [TransactionCategory]

    static let unavailable = TransactionCategoryState(
        isAvailable: false,
        selectedCategory: nil,
        availableCategories: []
    )

    static func available(with category: TransactionCategory?) -> TransactionCategoryState {
        TransactionCategoryState(
            isAvailable: true,
            selectedCategory: category,
            availableCategories: TransactionCategory.allCases
        )
    }
}

final class TransactionCategoryFilterNotifier {
    private let isEnabledPublisher: AnyPublisher<Bool, Never>
    private let stateSubject = CurrentValueSubject<TransactionCategoryState, Never>(.unavailable)
    private let categorySelectedSubject = PassthroughSubject<TransactionCategory?, Never>()
    private let categoryChangedSubject = PassthroughSubject<TransactionCategory?, Never>()
    private var cancellables = Set<AnyCancellable>()

    var state: TransactionCategoryState {
        stateSubject.value
    }

    var statePublisher: AnyPublisher<TransactionCategoryState, Never> {
        stateSubject.removeDuplicates().eraseToAnyPublisher()
    }

    var categoryChangedPublisher: AnyPublisher<TransactionCategory?, Never> {
        categoryChangedSubject.eraseToAnyPublisher()
    }

    init(isEnabledPublisher: AnyPublisher<Bool, Never>) {
        self.isEnabledPublisher = isEnabledPublisher
        setupBindings()
    }

    func reset() {
        cancellables = Set()
        setupBindings()
    }

    func select(_ category: TransactionCategory?) {
        categorySelectedSubject.send(category)
    }
}

extension TransactionCategoryFilterNotifier {
    private func setupBindings() {
        let isEnabled = isEnabledPublisher
            .prepend(false)
            .eraseToAnyPublisher()

        let selectCategory = categorySelectedSubject
            .prepend(nil)
            .eraseToAnyPublisher()

        Publishers.CombineLatest(selectCategory, isEnabled)
            .map(makeStateFactory())
            .assign(to: \.value, on: stateSubject)
            .store(in: &cancellables)

        Publishers.Zip(
            stateSubject.eraseToAnyPublisher(),
            stateSubject.dropFirst().eraseToAnyPublisher()
        )
        .filter { $0.selectedCategory != $1.selectedCategory }
        .map { $1.selectedCategory }
        .sink { [categoryChangedSubject] in
            categoryChangedSubject.send($0)
        }.store(in: &cancellables)
    }

    private func makeStateFactory() -> (TransactionCategory?, Bool) -> TransactionCategoryState {
        { category, isEnabled in
            isEnabled ? .available(with: category) : .unavailable
        }
    }
}
