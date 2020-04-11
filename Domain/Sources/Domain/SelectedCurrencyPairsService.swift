import Future

public protocol SelectedCurrencyPairsService {
    func selectedCurrencyPairs() -> AnyPublisher<[CurrencyPair], Error>
    func save(selectedPairs: [CurrencyPair]) -> AnyPublisher<Void, Error>
}

