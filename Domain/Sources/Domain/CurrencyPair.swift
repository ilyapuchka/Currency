import Foundation

public struct CurrencyPair: Equatable {
    public let from: Currency
    public let to: Currency
    public let rate: Decimal

    public init(from: Currency, to: Currency, rate: Decimal) {
        self.from = from
        self.to = to
        self.rate = rate
    }

    /// Returns amount in `from` currency converted to `to` currency
    public func convert(amount: Decimal) -> Decimal {
        amount * rate
    }
}
