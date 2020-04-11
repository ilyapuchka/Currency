import Future

public protocol SupportedCurrenciesService {
    func supportedCurrencies() -> AnyPublisher<[Currency], Error>
}
