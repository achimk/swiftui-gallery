import Foundation

protocol TransactionRepository {
    func findAll(for query: TransactionQuery) async throws -> [Transaction]
}
