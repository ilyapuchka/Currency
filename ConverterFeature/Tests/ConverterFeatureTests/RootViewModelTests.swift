import XCTest
@testable import ConverterFeature
@testable import DesignLibrary
import Future
import Domain

final class RootViewModelTests: XCTestCase, ViewModelTest {
    typealias ViewModel = RootViewModel
    typealias Event = RootEvent

    var state: RootState! = nil
    var effects: [Future<Event, Never>] = []
    var expectedEffects: [Future<Event, Never>] = []

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

    let selectedCurrencyPairsService = MockSelectedCurrencyPairsService()
    let ratesService = MockRatesService()
    let ratesObserving = MockRatesObserving()

    func makeReducer() -> ViewModel.Reducer<Event> {
        return RootViewModel.reduce(
            selectedCurrencyPairsService: selectedCurrencyPairsService,
            ratesService: ratesService,
            ratesObserving: ratesObserving
        )
    }

    func test_loadsPreviouslySelectedPairs_whenInitialized() throws {
        let selectedPair = CurrencyPair(from: "EUR", to: "USD")
        let exchangeRate = ExchangeRate(pair: selectedPair, rate: 1.23)

        var selectedCurrenciesCalled = false
        selectedCurrencyPairsService.stubSelectedCurrencyPairs = Future { promise in
            selectedCurrenciesCalled = true
            promise.fulfill(.success([selectedPair]))
        }

        var ratesServiceCalled = false
        ratesService.stubExchangeRates = { pairs in
            ratesServiceCalled = true
            XCTAssertEqual(pairs, [selectedPair])
            return .just([exchangeRate])
        }

        ratesObserving.update { [unowned ratesService] in
            ratesService.exchangeRates(pairs: [selectedPair])
        }

        state = RootState(status: .isLoading, observeUpdates: { _, _ in })

        try AssertSteps {
            try AssertEvent(.send(.initialised), expectedEffects: [
                Future<[CurrencyPair], Error>.just([selectedPair])
                    .flatMap { _ in .just([exchangeRate]) }
                    .map(RootEvent.loadedRates)
                    .ignoreError()
            ], expectedState: { _ in })

            XCTAssertTrue(selectedCurrenciesCalled)
            XCTAssertTrue(ratesServiceCalled)

            try AssertEvent(.receive(.loadedRates([exchangeRate]))) { (state) in
                state.rates = [exchangeRate]
                state.pairs = [selectedPair]
                state.status = .isLoaded
            }

            XCTAssertTrue(ratesObserving.startCalled)
        }
    }

    func test_canRetry_whenFailedToUpdateRates() throws {
        let selectedPair = CurrencyPair(from: "EUR", to: "USD")
        let exchangeRate = ExchangeRate(pair: selectedPair, rate: 1.23)
        let error = NSError(domain: "", code: 0, userInfo: nil)

        var selectedCurrenciesCalled = false
        selectedCurrencyPairsService.stubSelectedCurrencyPairs = Future { promise in
            selectedCurrenciesCalled = true
            promise.fulfill(.success([selectedPair]))
        }

        var ratesServiceCalled = false
        var ratesServiceRetried = false
        ratesService.stubExchangeRates = { pairs in
            XCTAssertEqual(pairs, [selectedPair])
            if ratesServiceCalled {
                ratesServiceRetried = true
                return .just([exchangeRate])
            } else {
                ratesServiceCalled = true
                return .just(error)
            }
        }

        state = RootState(status: .isLoading, observeUpdates: { _, _ in })

        try AssertSteps {
            try AssertEvent(.send(.initialised), expectedEffects: [
                Future.just([selectedPair])
                    .flatMap { _ in .just(error) }
                    .map(RootEvent.loadedRates)
                    .flatMapError { error in .just(.failedToGetRates([selectedPair], error)) }
            ], expectedState: { _ in })

            XCTAssertTrue(selectedCurrenciesCalled)
            XCTAssertTrue(ratesServiceCalled)
            XCTAssertFalse(ratesServiceRetried)

            try AssertEvent(.receive(.failedToGetRates([selectedPair], error))) { (state) in
                state.status = .isLoaded
                state.pairs = [selectedPair]
                state.error = NSError(domain: "", code: 0, userInfo: nil)
            }

            XCTAssertFalse(ratesServiceRetried)

            try AssertEvent(.send(.ui(.retry)), expectedEffects: [
                Future.just([selectedPair])
                    .flatMap { _ in .just([exchangeRate]) }
                    .map(RootEvent.loadedRates)
                    .flatMapError { error in .just(.failedToGetRates([selectedPair], error)) }
            ]) { (state) in
                state.status = .isLoading
            }

            XCTAssertTrue(ratesServiceRetried)

            try AssertEvent(.receive(.loadedRates([exchangeRate])), expectedEffects: []) { (state) in
                state.status = .isLoaded
                state.rates = [exchangeRate]
                state.error = nil
            }

            XCTAssertTrue(ratesObserving.startCalled)
        }
    }

    func test_canAddCurrencyPair() throws {
        let selectedPair = CurrencyPair(from: "EUR", to: "USD")
        let exchangeRate = ExchangeRate(pair: selectedPair, rate: 1.23)
        let addedPair = CurrencyPair(from: "USD", to: "EUR")
        let addedExchangeRate = ExchangeRate(pair: addedPair, rate: 0.8)

        var saveCalled = false
        selectedCurrencyPairsService.stubSave = { pairs in
            XCTAssertEqual(pairs, [addedPair, selectedPair])
            saveCalled = true
            return .just(())
        }

        var ratesServiceCalled = false
        ratesService.stubExchangeRates = { pairs in
            ratesServiceCalled = true
            XCTAssertEqual(pairs, [addedPair, selectedPair])
            return .just([addedExchangeRate, exchangeRate])
        }

        state = RootState(
            rates: [exchangeRate],
            pairs: [selectedPair],
            status: .isLoaded,
            observeUpdates: {_, _ in },
            error: nil
        )

        try AssertSteps {
            func AssertAddPair(_ addedPair: CurrencyPair?, expectedEffects: [Future<Event, Never>], line: UInt = #line) throws {
                let promise = Promise<CurrencyPair?, Never>()

                try AssertEvent(line: line, .send(.ui(.addPair)), expectedEffects: [
                    Future(promise: promise).map(RootEvent.added)
                ]) { (state) in
                    state.status = .addingPair(promise)
                }

                XCTAssertTrue(ratesObserving.pauseCalled, "Should pause updates while adding new pair", line: line)
                ratesObserving.pauseCalled = false

                promise.fulfill(.success(addedPair))

                try AssertEvent(line: line, .receive(.added(addedPair)), expectedEffects: expectedEffects) { (state) in
                    state.status = .isLoaded
                    if let addedPair = addedPair {
                        state.pairs = [addedPair, selectedPair]
                    }
                }

                XCTAssertTrue(ratesObserving.startCalled, "Should restart updates when canceled adding", line: line)
                ratesObserving.startCalled = false
            }

            // when adding started and canceled
            try AssertAddPair(nil, expectedEffects: [])

            // when adding started and completed
            try AssertAddPair(addedPair, expectedEffects: [
                Future<Void, Never>.just(()).ignoreError().flatMap { .empty }, // save updated pairs
                Future.just([addedExchangeRate, exchangeRate]).map(RootEvent.updatedRates) // update rate for added pair
            ])

            XCTAssertTrue(saveCalled)
            XCTAssertTrue(ratesServiceCalled)

            // save results are ignored
            try AssertEvent(.receive(nil), expectedState: { _ in })

            try AssertEvent(.receive(.updatedRates([addedExchangeRate, exchangeRate])), expectedEffects: []) { (state) in
                state.rates = [addedExchangeRate, exchangeRate]
            }

            XCTAssertTrue(ratesObserving.startCalled, "Should restart updates if needed when updated rates")
        }
    }

    func test_canDeleteCurrencyPair() throws {
        let selectedPair = CurrencyPair(from: "EUR", to: "USD")
        let exchangeRate = ExchangeRate(pair: selectedPair, rate: 1.23)

        var saveCalled = false
        selectedCurrencyPairsService.stubSave = { pairs in
            XCTAssertEqual(pairs, [])
            saveCalled = true
            return .just(())
        }

        state = RootState(
            rates: [exchangeRate],
            pairs: [selectedPair],
            status: .isLoaded,
            observeUpdates: { _, _ in },
            error: nil
        )

        try AssertSteps {
            try AssertEvent(.send(.ui(.deletePair(selectedPair))), expectedEffects: [
                Future<Void, Never>.just(()).ignoreError().flatMap { .empty } // save updated pairs
            ]) { (state) in
                state.rates.removeAll(where: { $0.pair == selectedPair })
                state.pairs.removeAll(where: { $0 == selectedPair })
            }

            XCTAssertTrue(saveCalled)

            // save results are ignored
            try AssertEvent(.receive(nil), expectedState: { _ in })
        }
    }
}
