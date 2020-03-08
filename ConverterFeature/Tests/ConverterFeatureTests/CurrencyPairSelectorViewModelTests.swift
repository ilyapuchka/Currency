import XCTest
@testable import ConverterFeature
@testable import DesignLibrary
import Future
import Domain

final class CurrencyPairSelectorViewModelTests: XCTestCase {
    class Service: SupportedCurrenciesService {
        var stubSupportedCurrencies: Future<[Currency], Error>!

        func supportedCurrencies() -> Future<[Currency], Error> {
            return stubSupportedCurrencies
        }
    }

    func test_canSelectPair() {
        let selected = Promise<CurrencyPair?, Never>()
        var selectedCurrency: CurrencyPair!
        selected.observe { (result) in
            selectedCurrency = try? result.get()
        }

        var state = CurrencyPairSelectorState(
            supported: [],
            disabled: [],
            selected: selected,
            status: .selectingFirstCurrency
        )

        assertEvent(state: &state, event: .loadedSupportedCurrencies(["EUR", "USD"])) { (state) in
            state.supported = ["EUR", "USD"]
        }
        assertEvent(state: &state, event: .ui(.selected("EUR"))) { (state) in
            state.status = .selectingSecondCurrency(first: "EUR")
        }

        XCTAssertNil(selectedCurrency)

        assertEvent(state: &state, event: .ui(.selected("USD"))) { _ in }

        XCTAssertEqual(selectedCurrency, CurrencyPair(from: "EUR", to: "USD"))
    }

    func test_loadsSupportedCurrencies_whenInitialized() {
        var state = CurrencyPairSelectorState(
            supported: [],
            disabled: [],
            selected: Promise<CurrencyPair?, Never>(),
            status: .selectingFirstCurrency
        )

        let service = Service()
        var supportedCurrenciesCalled = false
        service.stubSupportedCurrencies = Future { (promise) in
            supportedCurrenciesCalled = true
            promise.fulfill(.success(["EUR", "USD"]))
        }
        let reducer = CurrencyPairSelectorViewModel.reduce(supportedCurrenciesService: service)

        reducer(&state, .initialised).forEach { effect in
            effect.on(success: { (event) in
                _ = reducer(&state, event)
            })
        }

        XCTAssertTrue(supportedCurrenciesCalled)

        let expectedState = state
        state.supported = ["EUR", "USD"]

        XCTAssertEqual(String(describing: state), String(describing: expectedState))
    }

    private func assertEvent(
        state: inout CurrencyPairSelectorState,
        event: CurrencyPairSelectorEvent,
        file: StaticString = #file,
        line: UInt = #line,
        expectedState: (inout CurrencyPairSelectorState) -> Void
    ) {
        let reducer = CurrencyPairSelectorViewModel.reduce(supportedCurrenciesService: Service())

        _ = reducer(&state, event)

        var expectState = state
        expectedState(&expectState)

        XCTAssertEqual(String(describing: state), String(describing: expectState), file: file, line: line)
    }

}
