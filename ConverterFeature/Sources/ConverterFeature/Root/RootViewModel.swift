import Foundation
import DataAccess
import Domain
import Future
import DesignLibrary

protocol RootViewModelProtocol: ViewModelProtocol where
    State == RootState,
    UserAction == RootEvent.UserAction {
}

final class RootViewModel: RootViewModelProtocol {
    let state: StateMachine<RootState, RootEvent>

    init(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService
    ) {
        let ratesUpdateObserving = RatesUpdateObserving()

        state = StateMachine(
            initial: .init(rates: [], status: .isLoaded, rateUpdatesObserver: ratesUpdateObserving.observer),
            reduce: Self.reduce(
                selectedCurrencyPairsService: selectedCurrencyPairsService,
                ratesService: ratesService,
                ratesUpdateObserving: ratesUpdateObserving
            )
        )
        ratesUpdateObserving.observe { [state, ratesUpdateObserving] in
            ratesService
                .exchangeRates(pairs: state.state.pairs)
                .on(success: ratesUpdateObserving.post)
        }
        state.sink(event: .initialised)
    }

    static func reduce(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService,
        ratesUpdateObserving: RatesUpdateObserving
    ) -> (inout RootState, RootEvent) -> [Future<RootEvent, Never>] {
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
            case .added(nil):
                state.status = .isLoaded
                return []
            case let .added(pair?):
                state.status = .isLoaded
                state.pairs.insert(pair, at: 0)
                ratesUpdateObserving.start()

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
                ratesUpdateObserving.pause()
                state.status = .addingPair(promise)

                return [
                    Future(promise: promise).map(RootEvent.added)
                ]
            case let .ui(.deletePair(pair)):
                state.rates.removeAll(where: { $0.pair == pair })
                state.pairs.removeAll(where: { $0 == pair })

                if state.pairs.isEmpty {
                    ratesUpdateObserving.pause()
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
                    ratesUpdateObserving.start()
                }

                return []
            case let .updatedRates(rates):
                guard !rates.isEmpty else { return [] }

                state.rates = rates
                state.pairs = rates.map { $0.pair }

                state.status = .isLoaded

                return []
            case .updateRates:
                return [
                    ratesService
                        .exchangeRates(pairs: state.pairs)
                        .map(RootEvent.updatedRates)
                        .flatMapError { _ in .just(.updatedRates([])) }
                ]
            }
        }
    }

    func sendAction(_ action: RootEvent.UserAction) {
        state.sink(event: .ui(action))
    }

    func observeState(_ observer: @escaping (RootState) -> Void) {
        state.observeState(observer)
    }

    func addPair(_ observer: @escaping ([Currency], Promise<CurrencyPair?, Never>) -> Void) {
        state.observeState { (state) in
            if case let .addingPair(addedPair) = state.status {
                let disabled = state.pairs.reduce(into: [Currency](), { $0.append($1.from); $0.append($1.to) })
                observer(disabled, addedPair)
            }
        }
    }
}

struct RootState {
    var rates: [ExchangeRate] = []
    var pairs: [CurrencyPair] = []
    var status: Status
    let rateUpdatesObserver: RatesUpdateObserving.Observer

    enum Status {
        case loading
        case isLoaded
        case addingPair(Promise<CurrencyPair?, Never>)
    }
}

enum RootEvent {
    case initialised
    case loadedRates([ExchangeRate])
    case added(CurrencyPair?)
    case updateRates
    case updatedRates([ExchangeRate])
    case ui(UserAction)

    enum UserAction {
        case addPair
        case deletePair(CurrencyPair)
    }
}
