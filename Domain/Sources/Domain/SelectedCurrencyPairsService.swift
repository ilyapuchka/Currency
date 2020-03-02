import Future

public protocol SelectedCurrencyPairsService {
    func selectedCurrencyPairs() -> Future<[ExchangeRate], Error>
    func save(selectedPairs: [ExchangeRate]) -> Future<Void, Error>
}

