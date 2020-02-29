import Future

public protocol ExchangeRateService {
    func exchangeRates(pairs: [(from: Currency, to: Currency)]) -> Future<[CurrencyPair], Error>
}
