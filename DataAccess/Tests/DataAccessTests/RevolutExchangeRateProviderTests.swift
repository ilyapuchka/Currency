import XCTest
@testable import DataAccess
import Future
import Domain

final class RevolutExchangeRateServiceTests: XCTestCase {
    let pairs: [CurrencyPair] = [
        CurrencyPair(from: "USD", to: "GBP"),
        CurrencyPair(from: "GBP", to: "USD")
    ]
    let expectedURL = URL(string: "https://europe-west1-revolut-230009.cloudfunctions.net/revolut-ios?pairs=USDGBP&pairs=GBPUSD")!

    func test_makeURL() {
        let sut = RevolutExchangeRateService()
        let url = sut.makeURL(pairs: pairs)

        XCTAssertEqual(url, expectedURL)
    }

    func test_loads_data_from_url() throws {
        let data = """
        {"GBPUSD":1.2994,"USDGBP":0.7807}
        """.data(using: .utf8)!

        let urlSession = URLSessionMock(future: Future { (promise) in
            promise.fulfill(.success((data, nil)))
        }, expectedURL: expectedURL)
        let sut = RevolutExchangeRateService(session: urlSession)

        var result: [ExchangeRate]!
        sut.exchangeRates(pairs: pairs).on { result = try? $0.get() }

        result = try XCTUnwrap(result)

        let gbp = try XCTUnwrap(result.first(where: { $0.from == "GBP" }))
        XCTAssertEqual(gbp.rate, Decimal(string: "1.2994"))

        let usd = try XCTUnwrap(result.first(where: { $0.from == "USD" }))
        XCTAssertEqual(usd.rate, Decimal(string: "0.7807"))
    }
}

struct URLSessionMock: HTTPSession {
    let future: Future<(Data?, URLResponse?), Error>
    let expectedURL: URL

    func get(url: URL) -> Future<(Data?, URLResponse?), Error> {
        XCTAssertEqual(url, expectedURL)
        return future
    }
}
