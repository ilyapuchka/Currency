import Foundation
import DataAccess
import Domain
import Future
import DesignLibrary

protocol CurrencyPairSelectorViewModelProtocol: ViewModelProtocol where
    State == CurrencyPairSelectorState,
    UserAction == CurrencyPairSelectorEvent.UserAction {
}

struct CurrencyPairSelectorViewModel: CurrencyPairSelectorViewModelProtocol {
    private let state: StateMachine<CurrencyPairSelectorState, CurrencyPairSelectorEvent>

    init(
        supportedCurrenciesService: SupportedCurrenciesService,
        disabled: [CurrencyPair],
        selected: Promise<CurrencyPair?, Never>
    ) {
        state = StateMachine(
            initial: .init(
                supported: [],
                disabled: disabled,
                selected: selected,
                status: .selectingFirst
            ),
            reduce: Self.reduce(supportedCurrenciesService: supportedCurrenciesService)
        )
        state.sink(event: .initialised)
    }

    init(
        from: Currency,
        disabled: [CurrencyPair],
        supportedCurrenciesService: SupportedCurrenciesService,
        selected: Promise<CurrencyPair?, Never>
    ) {
        state = StateMachine(
            initial: .init(
                disabled: disabled,
                selected: selected,
                status: .selectingSecond(first: from)
            ),
            reduce: Self.reduce(supportedCurrenciesService: supportedCurrenciesService)
        )
        state.sink(event: .initialised)
    }

    static func reduce(
        supportedCurrenciesService: SupportedCurrenciesService
    ) -> (inout CurrencyPairSelectorState, CurrencyPairSelectorEvent) -> [Future<CurrencyPairSelectorEvent, Never>] {
        return { state, event in
            switch event {
            case .initialised:
                return [
                    supportedCurrenciesService.supportedCurrencies()
                        .map(CurrencyPairSelectorEvent.loadedSupportedCurrencies)
                        .flatMapError { _ in .empty }
                ]
            case let .loadedSupportedCurrencies(currencies):
                state.supported = currencies
                return []
            case let .ui(.selected(currency)):
                if let first = state.first {
                    state.selected.fulfill(.success(CurrencyPair(from: first, to: currency)))
                } else {
                    state.status = .selectingSecond(first: currency)
                }
                return []
            }
        }
    }

    func sendAction(_ action: CurrencyPairSelectorEvent.UserAction) {
        state.sink(event: .ui(action))
    }

    func observeState(_ observer: @escaping (CurrencyPairSelectorState) -> Void) {
        state.observeState(observer)
    }

    func selectSecond(_ observer: @escaping (Currency, [CurrencyPair], Promise<CurrencyPair?, Never>) -> Void) {
        state.observeState { (state) in
            if let first = state.first {
                observer(first, state.disabled, state.selected)
            }
        }
    }
}


struct CurrencyPairSelectorState {
    var supported: [Currency] = []
    let disabled: [CurrencyPair]
    let selected: Promise<CurrencyPair?, Never>

    var status: Status

    var first: Currency? {
        guard case let .selectingSecond(first) = status else {
            return nil
        }
        return first
    }

    func isEnabled(currency: Currency) -> Bool {
        guard let first = first else {
            return true
        }
        guard currency != first else {
            return false
        }
        let pair = CurrencyPair(from: first, to: currency)
        return !disabled.contains(pair)
    }

    enum Status {
        case selectingFirst
        case selectingSecond(first: Currency)
    }
}

enum CurrencyPairSelectorEvent {
    case initialised
    case loadedSupportedCurrencies([Currency])
    case ui(UserAction)

    enum UserAction {
        case selected(Currency)
    }
}
