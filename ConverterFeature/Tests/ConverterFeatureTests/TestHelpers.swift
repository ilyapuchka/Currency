import XCTest
@testable import ConverterFeature
@testable import DesignLibrary
import Future
import Domain

class StubViewModel<State, UserAction>: ViewModelProtocol {
    var receivedActions: [UserAction] = []

    func sendAction(_ action: UserAction) {
        receivedActions.append(action)
    }

    func observeState(sendInitial: Bool = false, _ observer: @escaping (State) -> Void) {

    }
}

extension AnyComponent {
    func unwrap<T: Component>(line: UInt = #line) throws -> T {
        try XCTUnwrap(wrapped as? AnyComponentBox<T>, line: line).wrapped
    }
}

protocol ViewModelTest: XCTestCase {
    associatedtype ViewModel: ViewModelProtocol
    associatedtype Event

    var state: ViewModel.State! { get set }
    var effects: [Future<Event, Never>] { get set }
    var expectedEffects: [Future<Event, Never>] { get set }

    func makeReducer() -> ViewModel.Reducer<Event>
}

enum ViewModelTestEvent<Event> {
    case send(Event), receive(Event?)
}

extension ViewModelTest {
    func AssertSteps(file: StaticString = #file, line: UInt = #line, _ steps: () throws -> Void) rethrows {
        try steps()
        XCTAssertTrue(expectedEffects.isEmpty, "Pending \(expectedEffects.count) side effects", file: file, line: line)
    }

    func AssertEvent(
        file: StaticString = #file,
        line: UInt = #line,
        _ event: ViewModelTestEvent<Event>,
        expectedEffects: [Future<Event, Never>] = [],
        expectedState: (inout ViewModel.State) -> Void
    ) throws {
        let reducer = makeReducer()

        switch event {
        case .receive(nil):
            // side effects can be ignored, passing nil is a way to instruct the test to expect that
            // in this case effect will be removed from the expected effects list
            _ = try XCTUnwrap(self.expectedEffects.first, "Unexpected received event", file: file, line: line)
            self.expectedEffects.removeFirst()
        case let .receive(event?):
            let expectedEffect = try XCTUnwrap(self.expectedEffects.first, "Unexpected received event", file: file, line: line)
            self.expectedEffects.removeFirst()

            var expectedEvent: Event!
            expectedEffect.on(success: { expectedEvent = $0 })

            try XCTAssertEqual(String(describing: event), String(describing: XCTUnwrap(expectedEvent)), file: file, line: line)

            // continue with handling state changes and side effects
            fallthrough
        case let .send(event):
            var expectState = state

            let effects = reducer(&state, event)
            self.expectedEffects.append(contentsOf: expectedEffects)

            expectedState(&expectState!)

            XCTAssertEqual(String(describing: state), String(describing: expectState), file: file, line: line)

            XCTAssertEqual(effects.count, expectedEffects.count, "Expected \(expectedEffects.count) effects, got \(effects.count)", file: file, line: line)

            if effects.count == expectedEffects.count {
                for (effect, expectedEffect) in zip(effects, expectedEffects) {
                    var event: Event!
                    effect.on(success: { event = $0 })

                    var expectedEvent: Event!
                    expectedEffect.on(success: { expectedEvent = $0 })

                    XCTAssertEqual(String(describing: event), String(describing: expectedEvent), file: file, line: line)
                }
            }
        }
    }
}

class MockSupportedCurrenciesService: SupportedCurrenciesService {
    var stubSupportedCurrencies: Future<[Currency], Error>!
    func supportedCurrencies() -> Future<[Currency], Error> {
        stubSupportedCurrencies
    }
}

class MockSelectedCurrencyPairsService: SelectedCurrencyPairsService {
    var stubSelectedCurrencyPairs: Future<[CurrencyPair], Error>!
    func selectedCurrencyPairs() -> Future<[CurrencyPair], Error> {
        stubSelectedCurrencyPairs
    }

    var stubSave: (([CurrencyPair]) -> Future<Void, Error>)!
    func save(selectedPairs: [CurrencyPair]) -> Future<Void, Error> {
        stubSave(selectedPairs)
    }
}

class MockRatesService: ExchangeRateService {
    var stubExchangeRates: (([CurrencyPair]) -> Future<[ExchangeRate], Error>)!
    func exchangeRates(pairs: [CurrencyPair]) -> Future<[ExchangeRate], Error> {
        stubExchangeRates(pairs)
    }
}

class MockRatesObserving: RatesUpdateObserving {
    var startCalled = false
    func start() {
        startCalled = true
    }
    var pauseCalled = false
    func pause() {
        pauseCalled = true
    }

    func observeUpdates(pair: CurrencyPair, update: @escaping (ExchangeRate) -> Void) {

    }

    func update(_ future: @escaping () -> Future<[ExchangeRate], Error>) {

    }
}
