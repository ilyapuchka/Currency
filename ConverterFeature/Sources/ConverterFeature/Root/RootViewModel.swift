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
                state.status = .loading

                return [
                    selectedCurrencyPairsService.selectedCurrencyPairs()
                        .flatMap { pairs in
                            pairs.isEmpty
                                ? .just(RootEvent.loadedRates([]))
                                : ratesService
                                    .exchangeRates(pairs: pairs)
                                    .map(RootEvent.loadedRates)
                        }
                        .flatMapError { _ in .just(.loadedRates([])) }
                ]
            case let .added(pair):
                state.status = .isLoaded

                guard let pair = pair else {
                    ratesObserving.start()
                    return []
                }

                state.pairs.insert(pair, at: 0)
                ratesObserving.start()

                return [
                    selectedCurrencyPairsService
                        .save(selectedPairs: state.pairs)
                        .ignoreError()
                        .flatMap { .empty },
                    ratesService
                        .exchangeRates(pairs: state.pairs)
                        .map(RootEvent.updatedRates)
                        .flatMapError { _ in .just(.updatedRates([])) }
                ]
            case .ui(.addPair):
                let promise = Promise<CurrencyPair?, Never>()
                ratesObserving.pause()
                state.status = .addingPair(promise)

                return [
                    Future(promise: promise).map(RootEvent.added)
                ]
            case let .ui(.deletePair(pair)):
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
            case let .loadedRates(rates):
                state.rates = rates
                state.pairs = rates.map { $0.pair }

                state.status = .isLoaded
                if !rates.isEmpty {
                    ratesObserving.start()
                }

                return []
            case let .updatedRates(rates):
                guard !rates.isEmpty else { return [] }

                state.rates = rates
                state.pairs = rates.map { $0.pair }

                state.status = .isLoaded

                return []
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

struct RootState {
    /// Current exchange rates
    var rates: [ExchangeRate] = []
    /// Currently selected pairs
    var pairs: [CurrencyPair] = []
    var status: Status
    /// Closure to add observer for provided currency pair exchange rate
    let observeUpdates: RatesUpdateObserving.AddObserver

    enum Status {
        case loading
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
    case ui(UserAction)

    enum UserAction {
        case addPair
        case deletePair(CurrencyPair)
    }
}
