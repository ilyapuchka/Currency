import Future

public protocol SelectedCurrencyPairsService {
    #if canImport(Combine)
    func selectedCurrencyPairs() -> AnyPublisher<[CurrencyPair], Error>
    func save(selectedPairs: [CurrencyPair]) -> AnyPublisher<Void, Error>
    #else
    func selectedCurrencyPairs() -> Future<[CurrencyPair], Error>
    func save(selectedPairs: [CurrencyPair]) -> Future<Void, Error>
    #endif
}

