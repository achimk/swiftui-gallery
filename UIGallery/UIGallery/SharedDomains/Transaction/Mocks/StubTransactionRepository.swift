import Foundation

class StubTransactionRepository: TransactionRepository {
    struct FindError: Error {
        let query: TransactionQuery
    }

    var transactionGenerator = StubTransactionGenerator()
    var delayInSeconds: UInt = 1
    var shouldSuccessForQuery: (TransactionQuery) -> Bool = { _ in true }

    func findAll(for query: TransactionQuery) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * UInt64(delayInSeconds))
        if !shouldSuccessForQuery(query) {
            throw FindError(query: query)
        }
        return transactionGenerator.build()
    }

    func update(category _: TransactionCategory, for _: UUID) async throws {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * UInt64(delayInSeconds))
    }
}
