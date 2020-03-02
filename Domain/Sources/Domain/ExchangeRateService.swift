import Future

public protocol ExchangeRateService {
    func exchangeRates(pairs: [CurrencyPair]) -> Future<[ExchangeRate], Error>
}
