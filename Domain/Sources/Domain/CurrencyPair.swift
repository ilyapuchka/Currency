public struct CurrencyPair: Equatable {
    public let from: Currency
    public let to: Currency

    public init(from: Currency, to: Currency) {
        self.from = from
        self.to = to
    }
}
