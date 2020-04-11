import Combine
import Domain
import Future

class CurrencyPairSelectorViewState: ObservableViewState {
    typealias State = CurrencyPairSelectorState
    typealias Event = CurrencyPairSelectorEvent
    typealias Action = CurrencyPairSelectorEvent.UserAction

    @Published private(set) var state: State
    private let input = PassthroughSubject<Event, Never>()
    private var bag = Set<AnyCancellable>()

    init(
        disabled: [CurrencyPair],
        selected: @escaping (CurrencyPair?) -> Void,
        supportedCurrenciesService: SupportedCurrenciesService
    ) {
        state = State(disabled: disabled)
        StateMachine.make(
            assignTo: \.state,
            on: self,
            input: input.sink,
            reduce: Self.reduce(
                supportedCurrenciesService: supportedCurrenciesService,
                selected: selected
            )
        ).store(in: &bag)
        input.send(.initialised)
    }

    func sendAction(_ action: Action) {
        input.send(.ui(action))
    }

    static func reduce(
        supportedCurrenciesService: SupportedCurrenciesService,
        selected: @escaping (CurrencyPair?) -> Void
    ) -> Reducer<State, Event> {
        return { state, event in
            switch event {
            case .initialised:
                return [
                    supportedCurrenciesService
                        .supportedCurrencies()
                        .map(Event.loadedSupportedCurrencies)
                        .mapError(Event.failed)
                        .eraseToAnyPublisher()
                ]
            case let .loadedSupportedCurrencies(currencies):
                state.currencies = currencies
                state.error = nil
                return []
            case let .failed(error):
                state.error = error
                return []
            case let .ui(.selected(currency)):
                if let currency = currency {
                    if let first = state.first {
                        state.second = currency
                        selected(CurrencyPair(from: first, to: currency))
                    } else {
                        state.first = currency
                    }
                }
                return []
            case .ui(.retry):
                return [
                    supportedCurrenciesService.supportedCurrencies()
                        .map(Event.loadedSupportedCurrencies)
                        .mapError(Event.failed)
                        .eraseToAnyPublisher()
                ]
            case .ui(.dismiss):
                if state.second == nil {
                    selected(nil)
                }
                return []
            }
        }
    }
}

struct CurrencyPairSelectorState {
    let disabled: [CurrencyPair]
    var currencies: [Currency] = []
    var first: Currency?
    var second: Currency?
    var error: Swift.Error?

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
}

enum CurrencyPairSelectorEvent {
    case initialised
    case loadedSupportedCurrencies([Currency])
    case failed(Error)
    case ui(UserAction)

    enum UserAction {
        case selected(Currency?)
        case retry
        case dismiss
    }
}
