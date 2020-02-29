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

    func makeURL(pairs: [(from: Currency, to: Currency)]) -> URL {
        var url = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        url.queryItems = pairs.map { (from, to) in
            URLQueryItem(name: "pairs", value: "\(from.code)\(to.code)")
        }
        return url.url!
    }

    public func exchangeRates(pairs: [(from: Currency, to: Currency)]) -> Future<[CurrencyPair], Swift.Error> {
        urlSession
            .get(url: makeURL(pairs: pairs))
            .flatMap { (data, _) in
                Future { promise in
                    guard let data = data else {
                        return promise.fulfill(.failure(Self.Error.noData))
                    }
                    promise.fulfill(
                        Result {
                            try JSONDecoder().decode(CurrencyPairs.self, from: data).pairs
                        }
                    )
                }
        }
    }
}
