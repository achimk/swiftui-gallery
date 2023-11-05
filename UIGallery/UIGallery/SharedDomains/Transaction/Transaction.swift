import Foundation

struct Transaction: Identifiable {
    let id: UUID
    let name: String
    let summary: String?
    let category: TransactionCategory
    let amount: Money
    let date: Date
}
