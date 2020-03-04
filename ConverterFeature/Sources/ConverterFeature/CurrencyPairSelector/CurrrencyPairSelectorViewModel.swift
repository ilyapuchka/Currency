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

    /**
     Creates a view model for selecting first currency
     - parameters:
        - disabled: currency pairs already selected by user
        - selected: a promise to fulfill when currency pair is selected
        - supportedCurrenciesService: a service to get supported currencies
     */
    init(
        disabled: [CurrencyPair],
        selected: Promise<CurrencyPair?, Never>,
        supportedCurrenciesService: SupportedCurrenciesService
    ) {
        state = StateMachine(
            initial: .init(
                supported: [],
                disabled: disabled,
                selected: selected,
                status: .selectingFirstCurrency
            ),
            reduce: Self.reduce(supportedCurrenciesService: supportedCurrenciesService)
        )
        state.sink(event: .initialised)
    }

    /**
     Creates a view model for selecting a second currency in a pair
     - parameters:
        - from: first selected currency
        - disabled: currency pairs already selected by user
        - selected: a promise to fulfill when currency pair is selected
        - supportedCurrenciesService: a service to get supported currencies
     */
    init(
        first: Currency,
        disabled: [CurrencyPair],
        selected: Promise<CurrencyPair?, Never>,
        supportedCurrenciesService: SupportedCurrenciesService
    ) {
        state = StateMachine(
            initial: .init(
                disabled: disabled,
                selected: selected,
                status: .selectingSecondCurrency(first: first)
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
                    state.status = .selectingSecondCurrency(first: currency)
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

    /// Adds observer for when user selects first currency in a pair
    func selectedFirst(_ observer: @escaping (Currency, [CurrencyPair], Promise<CurrencyPair?, Never>) -> Void) {
        state.observeState { (state) in
            if let first = state.first {
                observer(first, state.disabled, state.selected)
            }
        }
    }
}


struct CurrencyPairSelectorState {
    /// List of all supported currencies
    var supported: [Currency] = []
    /// List of already selected currency pairs that user should not be able to select again
    let disabled: [CurrencyPair]
    /// a promise that should be fulfilled with selected currency pair or with nil if selection is canceled
    let selected: Promise<CurrencyPair?, Never>

    var status: Status

    /// Already selected currency in a pair
    var first: Currency? {
        guard case let .selectingSecondCurrency(first) = status else {
            return nil
        }
        return first
    }

    /// Returns true if user should be able to select the currency
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
        case selectingFirstCurrency
        case selectingSecondCurrency(first: Currency)
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
