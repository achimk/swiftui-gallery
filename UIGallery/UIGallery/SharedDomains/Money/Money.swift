import Foundation

struct InconsistentCurrencyError: Error { }

struct Money {
    let amount: Amount
    let currency: Currency
}
    
extension Money {
    
    func add(_ amount: Amount) -> Money {
        return Money(amount: self.amount + amount, currency: currency)
    }
    
    func add(_ other: Money) throws -> Money {
        guard currency == other.currency else {
            throw InconsistentCurrencyError()
        }
        return Money(amount: amount + other.amount, currency: currency)
    }
}
