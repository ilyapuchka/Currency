import XCTest
@testable import DataAccess
import Domain

final class CurrencyPairDecodingTests: XCTestCase {
    func test_can_decode_currency_pairs() throws {
        let data = """
        {"GBPUSD":1.2994,"USDGBP":0.7807}
        """.data(using: .utf8)!

        let pairs = try JSONDecoder().decode(CurrencyPairs.self, from: data)

        XCTAssertTrue(pairs.pairs.contains(CurrencyPair(from: "GBP", to: "USD", rate: 1.2994)))
        XCTAssertTrue(pairs.pairs.contains(CurrencyPair(from: "USD", to: "GBP", rate: 0.7807)))
    }
}
