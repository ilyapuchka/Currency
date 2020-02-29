import Future

public protocol SelectedCurrencyPairsService {
    func selectedCurrencyPairs() -> Future<[CurrencyPair], Error>
    func save(selectedPairs: [CurrencyPair]) -> Future<Void, Error>
}

