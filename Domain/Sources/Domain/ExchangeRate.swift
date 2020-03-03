import Foundation

public struct ExchangeRate: Equatable {
    public let pair: CurrencyPair
    public let rate: Decimal

    public init(pair: CurrencyPair, rate: Decimal) {
        self.pair = pair
        self.rate = rate
    }

    /// Returns amount in `from` currency converted to `to` currency
    public func convert(amount: Decimal) -> Decimal {
        amount * rate
    }
}
