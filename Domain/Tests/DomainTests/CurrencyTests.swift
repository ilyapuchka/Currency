import XCTest
@testable import Domain

final class CurrencyTests: XCTestCase {
    func testCurrencyArithmetics() {
        let rate = ExchangeRate(
            from: "USD",
            to: "EUR",
            rate: 1.1629
        )

        XCTAssertEqual(rate.convert(amount: 0.5), 0.58145)
        XCTAssertEqual(rate.convert(amount: 1), 1.1629)
        XCTAssertEqual(rate.convert(amount: 1.5), 1.74435)
        XCTAssertEqual(rate.convert(amount: 2), 2.3258)
    }
}
