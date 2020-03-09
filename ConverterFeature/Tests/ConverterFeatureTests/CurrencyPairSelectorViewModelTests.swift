import XCTest
@testable import ConverterFeature
@testable import DesignLibrary
@testable import Future
import Domain

final class CurrencyPairSelectorViewModelTests: XCTestCase, ViewModelTest {
    typealias ViewModel = CurrencyPairSelectorViewModel
    typealias Event = CurrencyPairSelectorEvent

    var state: CurrencyPairSelectorState! = nil
    var effects: [Future<Event, Never>] = []
    var expectedEffects: [Future<Event, Never>] = []

    let service = MockSupportedCurrenciesService()

    func makeReducer() -> ViewModel.Reducer<Event> {
        CurrencyPairSelectorViewModel.reduce(supportedCurrenciesService: service)
    }

    func test_loadsSupportedCurrencies_whenInitialized() throws {
        var supportedCurrenciesCalled = false
        service.stubSupportedCurrencies = Future { (promise) in
            supportedCurrenciesCalled = true
            promise.fulfill(.success(["EUR", "USD"]))
        }

        state = CurrencyPairSelectorState(
            supported: [],
            disabled: [], selected: Promise<CurrencyPair?, Never>(),
            error: nil,
            status: .selectingFirstCurrency
        )

        try AssertSteps {
            try AssertEvent(.send(.initialised), expectedEffects: [
                Future<[Currency], Error>.just(["EUR", "USD"])
                    .map(CurrencyPairSelectorEvent.loadedSupportedCurrencies)
                    .ignoreError()
            ], expectedState: { _ in })

            XCTAssertTrue(supportedCurrenciesCalled)

            try AssertEvent(.receive(.loadedSupportedCurrencies(["EUR", "USD"]))) { state in
                state.supported = ["EUR", "USD"]
            }
        }
    }

    func test_canSelectPair() throws {
        var selectedCurrency: CurrencyPair!
        let selected = Promise<CurrencyPair?, Never>()
        selected.observe { (result) in
            selectedCurrency = try? result.get()
        }

        state = CurrencyPairSelectorState(
            supported: [],
            disabled: [],
            selected: selected,
            status: .selectingFirstCurrency
        )

        try AssertSteps {
            try AssertEvent(.send(.loadedSupportedCurrencies(["EUR", "USD"]))) { (state) in
                state.supported = ["EUR", "USD"]
            }

            try AssertEvent(.send(.ui(.selected("EUR")))) { (state) in
                state.status = .selectingSecondCurrency(first: "EUR")
            }

            XCTAssertNil(selectedCurrency)

            try AssertEvent(.send(.ui(.selected("USD")))) { _ in }

            XCTAssertEqual(selectedCurrency, CurrencyPair(from: "EUR", to: "USD"))
        }
    }

    func test_disablesAlreadySelectedPairs() {
        state = CurrencyPairSelectorState(
            supported: ["EUR", "USD"],
            disabled: [CurrencyPair(from: "EUR", to: "USD")],
            selected: .init(),
            status: .selectingFirstCurrency
        )

        XCTAssertTrue(state.isEnabled(currency: "EUR"))
        XCTAssertTrue(state.isEnabled(currency: "USD"))

        state.status = .selectingSecondCurrency(first: "EUR")

        XCTAssertFalse(state.isEnabled(currency: "EUR"))
        XCTAssertFalse(state.isEnabled(currency: "USD"))

        state.status = .selectingSecondCurrency(first: "USD")

        XCTAssertFalse(state.isEnabled(currency: "USD"))
        XCTAssertTrue(state.isEnabled(currency: "EUR"))
    }

}
