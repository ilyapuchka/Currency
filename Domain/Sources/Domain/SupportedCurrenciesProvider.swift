import Future

public protocol SupportedCurrenciesService {
    func supportedCurrencies() -> Future<[Currency], Error>
}
