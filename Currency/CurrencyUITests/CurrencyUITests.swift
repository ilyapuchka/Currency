import XCTest
import Domain

class CurrencyUITests: XCTestCase {
    func test_addingNewPair_fromEmptyState() {
        App()
            // given I start with an empty list
            .launchWithSelectedPairs(selectedPairs: [])
            // when I tap on add button
            .tapAddCurrencyButton()
            // when I selected the first currency
            .selectCurrency("EUR")
            // when I select the second currency
            .selectSecondCurrency("USD")
            // then I see the list with selected currency pair
            .waitForCurrencyPairViewToExist("EURUSD", at: 1)
            // when I tap on add button
            .tapAddCurrencyButton()
            // when I selected the first currency
            .selectCurrency("EUR")
            // when I select the second currency
            .selectSecondCurrency("AUD")
            // then I see the list with the first selected currency pair
            .waitForCurrencyPairViewToExist("EURAUD", at: 1)
            // and I see the list with the second selected currency pair
            .waitForCurrencyPairViewToExist("EURUSD", at: 2)

        App()
            // when I restart the app
            .terminate().launchWithSelectedPairs(selectedPairs: ["EURAUD", "EURUSD"])
            // then I see the list with the first selected currency pair
            .waitForCurrencyPairViewToExist("EURAUD", at: 1)
            // and I see the list with the second selected currency pair
            .waitForCurrencyPairViewToExist("EURUSD", at: 2)
    }

    func test_deletingPair() {
        App()
            // given I start with non empty list
            .launchWithSelectedPairs(selectedPairs: ["EURJPY", "EURUSD"])
            // when I delete pair
            .deleteCurrency(at: 1)
            // then the pair is removed from the list
            .waitForCurrencyPairViewToNotExist("EURJPY", at: 1)
            // and another pair is visible
            .waitForCurrencyPairViewToExist("EURUSD", at: 1)
            // and when I delete the last pair
            .deleteCurrency(at: 1)
            // I see empty view
            .waitForEmptyViewToExist()
    }
}
