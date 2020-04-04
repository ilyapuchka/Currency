import Future

public protocol ExchangeRateService {
    #if canImport(Combine)
    func exchangeRates(pairs: [CurrencyPair]) -> AnyPublisher<[ExchangeRate], Error>
    #else
    func exchangeRates(pairs: [CurrencyPair]) -> Future<[ExchangeRate], Error>
    #endif
}
