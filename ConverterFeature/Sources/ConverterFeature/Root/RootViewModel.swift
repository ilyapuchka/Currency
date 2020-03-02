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
    let updateTimer = Timer(repeatInterval: 1)

    init(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService
    ) {
        state = StateMachine(
            initial: .init(rates: [], status: .isLoaded),
            reduce: Self.reduce(
                selectedCurrencyPairsService: selectedCurrencyPairsService,
                ratesService: ratesService,
                updateTimer: updateTimer
            )
        )
        updateTimer.observe { [state] in
            state.sink(event: .updateRates)
        }
        state.sink(event: .initialised)
    }

    static func reduce(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService,
        updateTimer: Timer
    ) -> (inout RootState, RootEvent) -> [Future<RootEvent, Never>] {
        return { state, event in
            switch event {
            case .initialised:
                state.status = .loading

                return [
                    selectedCurrencyPairsService.selectedCurrencyPairs()
                        .map(RootEvent.loaded)
                        .flatMapError { _ in .just(.loaded([])) }
                ]
            case let .loaded(selected):
                state.rates.append(contentsOf: selected)
                state.pairs.append(contentsOf: selected.map {
                    CurrencyPair(from: $0.from, to: $0.to)
                })

                state.status = .isLoaded
                if state.pairs.isEmpty {
                    updateTimer.pause()
                }

                return []
            case .added(nil):
                state.status = .isLoaded
                return []
            case let .added(pair?):
                state.status = .isLoaded
                state.pairs.append(pair)
                updateTimer.start()

                return [
                    ratesService
                        .exchangeRates(pairs: state.pairs)
                        .map(RootEvent.updatedRates)
                        .flatMapError { _ in .just(.loaded([])) }
                ]
            case .ui(.addPair):
                let promise = Promise<CurrencyPair?, Never>()
                state.status = .addingPair(promise)

                return [
                    // go idle right away to stop timer and prevent repeated presentations
                    Future.just(.idle),
                    Future(promise: promise).map(RootEvent.added)
                ]
            case let .updatedRates(rates):
                state.rates = rates

                return []
            case .updateRates:
                return [
                    ratesService
                        .exchangeRates(pairs: state.pairs)
                        .map(RootEvent.updatedRates)
                        .flatMapError { _ in .just(.loaded([])) }
                ]
            case .idle:
                state.status = .isLoaded
                updateTimer.pause()

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

    func addPair(_ observer: @escaping (Promise<CurrencyPair?, Never>) -> Void) {
        state.observeState { (state) in
            if case let .addingPair(addedPair) = state.status {
                observer(addedPair)
            }
        }
    }
}

struct RootState {
    var rates: [ExchangeRate] = []
    var pairs: [CurrencyPair] = []
    var status: Status

    enum Status {
        case loading
        case isLoaded
        case addingPair(Promise<CurrencyPair?, Never>)
    }
}

enum RootEvent {
    case initialised
    case loaded([ExchangeRate])
    case added(CurrencyPair?)
    case updateRates
    case updatedRates([ExchangeRate])
    case idle
    case ui(UserAction)

    enum UserAction {
        case addPair
    }
}
