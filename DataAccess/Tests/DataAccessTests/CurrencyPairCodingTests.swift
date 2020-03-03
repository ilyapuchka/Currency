import XCTest
@testable import DataAccess
import Domain

final class CurrencyPairDecodingTests: XCTestCase {
    func test_exchangeRate_Decodable() throws {
        let data = """
        {"GBPUSD":1.2994,"USDGBP":0.7807}
        """.data(using: .utf8)!

        let pairs = try JSONDecoder().decode(ExchangeRates.self, from: data)

        let gbp = try XCTUnwrap(pairs.rates.first(where: { $0.pair.from == "GBP" }))
        // Decimal created from float literal also results in loss of precision
        // https://bugs.swift.org/browse/SR-3317
        XCTAssertEqual(gbp.rate, Decimal(string: "1.2994"))

        let usd = try XCTUnwrap(pairs.rates.first(where: { $0.pair.from == "USD" }))
        XCTAssertEqual(usd.rate, Decimal(string: "0.7807"))
    }

    func test_currencyPair_Codable() throws {
        let pairs = [CurrencyPair(from: "USD", to: "GBP"), CurrencyPair(from: "GBP", to: "USD")]
        let data = try JSONEncoder().encode(pairs)
        let decoded = try JSONDecoder().decode([CurrencyPair].self, from: data)

        XCTAssertEqual(pairs, decoded)
    }
}
