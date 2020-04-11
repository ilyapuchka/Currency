import Combine
import Domain
import Future
import Foundation

class RootViewState: ObservableViewState {
    typealias State = RootState
    typealias Event = RootEvent
    typealias Action = RootEvent.UserAction

    @Published private(set) var state: State
    private let input = PassthroughSubject<Event, Never>()
    private var bag = Set<AnyCancellable>()

    init(
        initial: State = .init(),
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService,
        ratesObserving: RatesUpdateObserving
    ) {
        state = initial
        StateMachine.make(
            assignTo: \.state,
            on: self,
            input: input.sink,
            reduce: Self.reduce(
                selectedCurrencyPairsService: selectedCurrencyPairsService,
                ratesService: ratesService,
                ratesObserving: ratesObserving
            )
        ).store(in: &bag)

        ratesObserving.update(subscriber: Subscribers.Assign(object: self, keyPath: \.state.rates)) {
            ratesService.exchangeRates(pairs: self.state.pairs)
        }

        input.send(.initialised)
    }

    func sendAction(_ action: Action) {
        input.send(.ui(action))
    }

    static func reduce(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService,
        ratesObserving: RatesUpdateObserving
    ) -> Reducer<State, Event> {
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
                return failedToUpdateRates(
                    state: &state,
                    pairs: pairs,
                    error: error
                )
            case let .ui(.added(pair)):
                return addedCurrencyPair(
                    state: &state,
                    pair: pair,
                    selectedCurrencyPairsService: selectedCurrencyPairsService,
                    ratesService: ratesService,
                    ratesObserving: ratesObserving
                )
            case .ui(.addPair):
                return addPair(state: &state, ratesObserving: ratesObserving)
            case let .ui(.deletePair(removed)):
                return deletePair(
                    state: &state,
                    removed: removed,
                    selectedCurrencyPairsService: selectedCurrencyPairsService,
                    ratesObserving: ratesObserving
                )
            case .ui(.retry):
                return retry(state: &state, ratesService: ratesService)
            }
        }
    }

}

extension RootViewState {
    static func loadPreviouslySelectedPairs(
        state: inout RootViewState.State,
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService
    ) -> [AnyPublisher<RootEvent, Never>] {
        state.status = .isLoading
        return [
            selectedCurrencyPairsService
                .selectedCurrencyPairs()
                .mapError { _ in [] }
                .flatMap { pairs in
                    pairs.isEmpty
                        ? Just(Event.loadedRates([])).eraseToAnyPublisher()
                        : ratesService.exchangeRates(pairs: pairs)
                            .map(Event.loadedRates)
                            .mapError { error in Event.failedToGetRates(pairs, error) }
                            .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        ]
    }

    static func loadedPreviouslySelectedPairs(
        state: inout RootState,
        rates: ([ExchangeRate]),
        ratesObserving: RatesUpdateObserving
    ) -> [AnyPublisher<RootEvent, Never>] {
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
    ) -> [AnyPublisher<RootEvent, Never>] {
        guard !rates.isEmpty else { return [] }

        state.rates = rates
        state.pairs = rates.map { $0.pair }
        state.error = nil
        ratesObserving.start()
        state.status = .isLoaded

        return []
    }

    static func failedToUpdateRates(
        state: inout RootState,
        pairs: [CurrencyPair],
        error: Error
    ) -> [AnyPublisher<RootEvent, Never>] {
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
    ) -> [AnyPublisher<RootEvent, Never>] {
        if !state.rates.isEmpty {
            ratesObserving.start()
        }
        state.status = .isLoaded

        guard let pair = pair else {
            return []
        }

        state.pairs.insert(pair, at: 0)

        return [
            selectedCurrencyPairsService
                .save(selectedPairs: state.pairs)
                .ignoreError()
                .flatMap { Empty() }
                .eraseToAnyPublisher(),
            ratesService
                .exchangeRates(pairs: state.pairs)
                .map(Event.updatedRates)
                // We could display alert when update fails, for now just ignore errors here,
                // they will be recovered on restart
                .ignoreError()
                .eraseToAnyPublisher(),
        ]
    }

    static func addPair(
        state: inout RootState,
        ratesObserving: RatesUpdateObserving
    ) -> [AnyPublisher<RootEvent, Never>] {
        state.status = .addingPair
        ratesObserving.pause()
        return []
    }

    static func deletePair(
        state: inout RootState,
        removed: IndexSet,
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesObserving: RatesUpdateObserving
    ) -> [AnyPublisher<RootEvent, Never>] {
        state.pairs.remove(atOffsets: removed)
        state.rates.remove(atOffsets: removed)

        if state.pairs.isEmpty {
            ratesObserving.pause()
        }

        return [
            selectedCurrencyPairsService
                .save(selectedPairs: state.pairs)
                .ignoreError()
                .flatMap { Empty() }
                .eraseToAnyPublisher()
        ]
    }

    static func retry(
        state: inout RootState,
        ratesService: ExchangeRateService
    ) -> [AnyPublisher<RootEvent, Never>] {
        state.status = .isLoading

        return [
            ratesService
                .exchangeRates(pairs: state.pairs)
                .map(Event.loadedRates)
                .mapError { [pairs = state.pairs] error in Event.failedToGetRates(pairs, error) }
                .eraseToAnyPublisher(),
        ]
    }
}

struct RootState {
    var rates: [ExchangeRate] = []
    var pairs: [CurrencyPair] = []
    var status: Status = .isLoading
    var error: Error?

    var isLoading: Bool {
        if case .isLoading = status { return true }
        else { return false }
    }

    var isAddingPair: Bool {
        if case .addingPair = status { return true }
        else { return false }
    }

    enum Status {
        case isLoading
        case isLoaded
        case addingPair
    }
}

enum RootEvent {
    case initialised
    /// Got rates for previously selected pairs
    case loadedRates([ExchangeRate])
    /// Failed to get exchange rates for previously selected pairs
    case failedToGetRates([CurrencyPair], Error)
    /// Updated exchange rates
    case updatedRates([ExchangeRate])
    case ui(UserAction)

    enum UserAction {
        case addPair
        /// Added a pair or canceled selection if nil
        case added(CurrencyPair?)
        case deletePair(IndexSet)
        case retry
    }
}
