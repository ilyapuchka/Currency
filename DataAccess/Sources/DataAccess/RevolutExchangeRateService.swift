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

    public func exchangeRates(pairs: [CurrencyPair]) -> Future<[ExchangeRate], Swift.Error> {
        urlSession
            .get(url: makeURL(pairs: pairs))
            .flatMap { (data, _) in
                Future { promise in
                    guard let data = data else {
                        return promise.fulfill(.failure(Self.Error.noData))
                    }
                    promise.fulfill(
                        Result {
                            try JSONDecoder().decode(CurrencyPairs.self, from: data)
                                .pairs
                                .filter { pairs.contains(CurrencyPair(from: $0.from, to: $0.to)) }
                                .sorted { lhs, rhs in
                                    let lhsIndex = pairs.firstIndex(of: CurrencyPair(from: lhs.from, to: lhs.to))!
                                    let rhsIndex = pairs.firstIndex(of: CurrencyPair(from: rhs.from, to: rhs.to))!
                                    return lhsIndex < rhsIndex
                            }
                        }
                    )
                }
        }
    }
}
