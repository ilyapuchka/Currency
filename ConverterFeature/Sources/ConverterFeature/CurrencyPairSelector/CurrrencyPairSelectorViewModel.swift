import Foundation
import DataAccess
import Domain
import Future
import DesignLibrary

protocol CurrencyPairSelectorViewModelProtocol: ViewModelProtocol where
    State == CurrencyPairSelectorState,
    UserAction == CurrencyPairSelectorEvent.UserAction {
}

final class CurrencyPairSelectorViewModel: CurrencyPairSelectorViewModelProtocol {
    private let state: StateMachine<CurrencyPairSelectorState, CurrencyPairSelectorEvent>

    init(
        supportedCurrenciesService: SupportedCurrenciesService,
        selected: Promise<CurrencyPair?, Never>
    ) {
        state = StateMachine(
            initial: .init(supported: [], status: .selectingFirst, selected: selected),
            reduce: Self.reduce(supportedCurrenciesService: supportedCurrenciesService)
        )
        state.sink(event: .initialised)
    }

    init(
        from: Currency,
        supportedCurrenciesService: SupportedCurrenciesService,
        selected: Promise<CurrencyPair?, Never>
    ) {
        state = StateMachine(
            initial: .init(status: .selectingSecond(first: from), selected: selected),
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

    func selectSecond(_ observer: @escaping (Currency, Promise<CurrencyPair?, Never>) -> Void) {
        state.observeState { (state) in
            if let first = state.first {
                observer(first, state.selected)
            }
        }
    }
}


struct CurrencyPairSelectorState {
    var supported: [Currency] = []
    var status: Status
    let selected: Promise<CurrencyPair?, Never>

    var first: Currency? {
        guard case let .selectingSecond(first) = status else {
            return nil
        }
        return first
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
