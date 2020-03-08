import Foundation
import DataAccess
import Domain
import Future
import DesignLibrary

struct RootViewModel: ViewModelProtocol {
    let state: StateMachine<RootState, RootEvent>

    init(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService
    ) {
        let ratesObserving = RatesUpdateObserving()

        state = StateMachine(
            initial: .init(
                status: .isLoaded,
                observeUpdates: ratesObserving.observeUpdates
            ),
            reduce: Self.reduce(
                selectedCurrencyPairsService: selectedCurrencyPairsService,
                ratesService: ratesService,
                ratesObserving: ratesObserving
            )
        )
        ratesObserving.update { [unowned state] in
            ratesService.exchangeRates(pairs: state.state.pairs)
        }
        state.sink(event: .initialised)
    }

    static func reduce(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService,
        ratesObserving: RatesUpdateObserving
    ) -> Reducer<RootEvent> {
        return { state, event in
            switch event {
            case .initialised:
                return loadPreviouslySelectedPairs(
                    state: &state,
                    selectedCurrencyPairsService: selectedCurrencyPairsService,
                    ratesService: ratesService
                )
            case let .loadedRates(rates):
                return loadedPreviouslySelectedPairs(
                    state: &state,
                    rates: rates,
                    ratesObserving: ratesObserving
                )
            case let .updatedRates(rates):
                return updatedRates(
                    state: &state,
                    rates: rates,
                    ratesObserving: ratesObserving
                )
            case let .failedToGetRates(pairs, error):
                return failedToUpdateRates(state: &state, pairs: pairs, error: error)
            case let .added(pair):
                return addedCurrencyPair(
                    state: &state,
                    pair: pair,
                    selectedCurrencyPairsService: selectedCurrencyPairsService,
                    ratesService: ratesService,
                    ratesObserving: ratesObserving
                )
            case .ui(.addPair):
                return addPair(state: &state, ratesObserving: ratesObserving)
            case let .ui(.deletePair(pair)):
                return deletePair(
                    state: &state,
                    pair: pair,
                    selectedCurrencyPairsService: selectedCurrencyPairsService,
                    ratesObserving: ratesObserving
                )
            case .ui(.retry):
                return retry(state: &state, ratesService: ratesService)
            }
        }
    }

    func sendAction(_ action: RootEvent.UserAction) {
        state.sink(event: .ui(action))
    }

    func observeState(_ observer: @escaping (RootState) -> Void) {
        state.observeState(observer)
    }

    /// Adds observer for when user wants to add a new pair
    func addPair(_ observer: @escaping ([CurrencyPair], Promise<CurrencyPair?, Never>) -> Void) {
        state.observeState { (state) in
            if case let .addingPair(addedPair) = state.status {
                observer(state.pairs, addedPair)
            }
        }
    }
}

private extension RootViewModel {
    static func loadPreviouslySelectedPairs(
        state: inout RootState,
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService
    ) -> [Future<RootEvent, Never>] {
        state.status = .isLoading

        return [
            selectedCurrencyPairsService.selectedCurrencyPairs()
                .flatMap { pairs in
                    pairs.isEmpty
                        ? .just(RootEvent.loadedRates([]))
                        : ratesService
                            .exchangeRates(pairs: pairs)
                            .map(RootEvent.loadedRates)
                            .flatMapError { error in
                                .just(.failedToGetRates(pairs, error))
                            }
                }
                .flatMapError { _ in .just(.loadedRates([])) }
        ]
    }

    static func loadedPreviouslySelectedPairs(
        state: inout RootState,
        rates: [ExchangeRate],
        ratesObserving: RatesUpdateObserving
    ) -> [Future<RootEvent, Never>] {
        state.rates = rates
        state.pairs = rates.map { $0.pair }
        state.error = nil

        state.status = .isLoaded
        if !rates.isEmpty {
            ratesObserving.start()
        }

        return []
    }

    static func updatedRates(
        state: inout RootState,
        rates: [ExchangeRate],
        ratesObserving: RatesUpdateObserving
    ) -> [Future<RootEvent, Never>] {
        guard !rates.isEmpty else { return [] }

        state.rates = rates
        state.pairs = rates.map { $0.pair }
        ratesObserving.start()
        state.status = .isLoaded

        return []
    }

    static func failedToUpdateRates(
        state: inout RootState,
        pairs: [CurrencyPair],
        error: Error
    ) -> [Future<RootEvent, Never>] {
        state.pairs = pairs
        state.error = error
        state.status = .isLoaded
        return []
    }

    static func addedCurrencyPair(
        state: inout RootState,
        pair: CurrencyPair?,
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService,
        ratesObserving: RatesUpdateObserving
    ) -> [Future<RootEvent, Never>] {
        if !state.rates.isEmpty {
            ratesObserving.start()
        }
        state.status = .isLoaded

        guard let addedPair = pair else {
            return []
        }

        state.pairs.insert(addedPair, at: 0)
        let pairs = state.pairs

        return [
            selectedCurrencyPairsService
                .save(selectedPairs: pairs)
                .ignoreError()
                .flatMap { .empty },
            ratesService
                .exchangeRates(pairs: pairs)
                .map(RootEvent.updatedRates)
                .flatMapError { error in .just(.failedToGetRates(pairs, error)) }
        ]
    }

    static func addPair(
        state: inout RootState,
        ratesObserving: RatesUpdateObserving
    ) -> [Future<RootEvent, Never>] {
        let promise = Promise<CurrencyPair?, Never>()
        ratesObserving.pause()
        state.status = .addingPair(promise)

        return [
            Future(promise: promise).map(RootEvent.added)
        ]
    }

    static func deletePair(
        state: inout RootState,
        pair: CurrencyPair,
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesObserving: RatesUpdateObserving
    ) -> [Future<RootEvent, Never>] {
        state.rates.removeAll(where: { $0.pair == pair })
        state.pairs.removeAll(where: { $0 == pair })

        if state.pairs.isEmpty {
            ratesObserving.pause()
        }

        return [
            selectedCurrencyPairsService
                .save(selectedPairs: state.pairs)
                .ignoreError()
                .flatMap { .empty },
        ]
    }

    static func retry(state: inout RootState, ratesService: ExchangeRateService) -> [Future<RootEvent, Never>] {
        state.status = .isLoading
        let pairs = state.pairs
        return [
            ratesService
                .exchangeRates(pairs: pairs)
                .map(RootEvent.loadedRates)
                .flatMapError { error in .just(.failedToGetRates(pairs, error)) }
        ]
    }
}

struct RootState {
    /// Current exchange rates
    var rates: [ExchangeRate] = []
    /// Currently selected pairs
    var pairs: [CurrencyPair] = []
    var status: Status
    /// Closure to add observer for provided currency pair exchange rate
    let observeUpdates: RatesUpdateObserving.AddObserver
    var error: Error?

    enum Status {
        case isLoading
        case isLoaded
        case addingPair(Promise<CurrencyPair?, Never>)
    }
}

enum RootEvent {
    case initialised
    /// Got rates for previously selected pairs
    case loadedRates([ExchangeRate])
    /// Added a pair or canceled selection if nil
    case added(CurrencyPair?)
    /// Updated exchange rates
    case updatedRates([ExchangeRate])
    case failedToGetRates([CurrencyPair], Error)
    case ui(UserAction)

    enum UserAction {
        case addPair
        case deletePair(CurrencyPair)
        case retry
    }
}
