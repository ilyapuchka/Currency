import Future

public protocol ExchangeRateService {
    func exchangeRates(pairs: [CurrencyPair]) -> AnyPublisher<[ExchangeRate], Error>
}
