import XCTest
@testable import DataAccess
import Domain

final class CurrencyPairDecodingTests: XCTestCase {
    func test_can_decode_currency_pairs() throws {
        let data = """
        {"GBPUSD":1.2994,"USDGBP":0.7807}
        """.data(using: .utf8)!

        let pairs = try JSONDecoder().decode(CurrencyPairs.self, from: data)

        let gbp = try XCTUnwrap(pairs.pairs.first(where: { $0.from == "GBP" }))
        // Decimal created from float literal also results in loss of precision
        // https://bugs.swift.org/browse/SR-3317
        XCTAssertEqual(gbp.rate, Decimal(string: "1.2994"))

        let usd = try XCTUnwrap(pairs.pairs.first(where: { $0.from == "USD" }))
        XCTAssertEqual(usd.rate, Decimal(string: "0.7807"))
    }
}
