import Foundation

protocol TransactionRepository {
    func findAll(for query: TransactionQuery) async throws -> [Transaction]
    func update(category: TransactionCategory, for transactionId: UUID) async throws
}
