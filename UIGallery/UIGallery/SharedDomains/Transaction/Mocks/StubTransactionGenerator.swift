import Foundation

struct StubTransactionGenerator {
    var idGenerator: (Int) -> UUID = { _ in UUID() }
    var categoryGenerator: (Int) -> TransactionCategory = {
        TransactionCategory(rawValue: $0 % TransactionCategory.allCases.count) ?? .other
    }
    var amountGenerator: (Int) -> Money = { Money(amount: .init(integerLiteral: $0), currency: .USD) }
    var dateGenerator: (Int) -> Date = { _ in  Date() }
    var offset: Int = 0
    var items: Int = 10
    
    func build() -> [Transaction] {
        let startIndex = offset
        let endIndex = offset + items
        return (startIndex..<endIndex).map(makeTransaction(at:))
    }
    
    private func makeTransaction(at index: Int) -> Transaction {
        Transaction(
            id: idGenerator(index),
            name: "Transaction \(index)",
            summary: "Here is a description of accepted and published transaction.",
            category: categoryGenerator(index),
            amount: amountGenerator(index),
            date: dateGenerator(index)
        )
    }
}
