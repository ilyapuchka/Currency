import Foundation
import Domain
import Future

public struct RevolutExchangeRateService: ExchangeRateService {
    public enum Error: Swift.Error {
        case noData
    }

    let baseURL = URL(string: "https://europe-west1-revolut-230009.cloudfunctions.net/revolut-ios")!
    let urlSession: HTTPSession

    public init(session: HTTPSession = URLSession.shared) {
        self.urlSession = session
    }

    func makeURL(pairs: [CurrencyPair]) -> URL {
        var url = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        url.queryItems = pairs.map {
            URLQueryItem(name: "pairs", value: "\($0.from.code)\($0.to.code)")
        }
        return url.url!
    }

    public func exchangeRates(pairs: [CurrencyPair]) -> AnyPublisher<[ExchangeRate], Swift.Error> {
        urlSession.get(url: makeURL(pairs: pairs))
            .tryMap { (data, _) in
                try JSONDecoder().decode(ExchangeRates.self, from: data)
                    .rates
                    .filter { pairs.contains($0.pair) }
                    .sorted { lhs, rhs in
                        let lhsIndex = pairs.firstIndex(of: lhs.pair)!
                        let rhsIndex = pairs.firstIndex(of: rhs.pair)!
                        return lhsIndex < rhsIndex
                }
        }.eraseToAnyPublisher()
    }
}
