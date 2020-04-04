import Future

public protocol SupportedCurrenciesService {
    #if canImport(Combine)
    func supportedCurrencies() -> AnyPublisher<[Currency], Error>
    #else
    func supportedCurrencies() -> Future<[Currency], Error>
    #endif
}
