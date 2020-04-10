import Combine
import DataAccess
import Domain
import Future

class CurrencyPairSelectorViewState: ObservableViewState {
    typealias State = CurrencyPairSelectorState
    typealias Event = CurrencyPairSelectorEvent

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

    func isEnabled(currency: Currency) -> Bool {
        guard let first = state.first else {
            return true
        }
        guard currency != state.first else {
            return false
        }
        let pair = CurrencyPair(from: first, to: currency)
        return !state.disabled.contains(pair)
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
                        .catch { error in Just(.failed(error)) }
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
                        selected(CurrencyPair(from: first, to: currency))
                    } else {
                        state.first = currency
                    }
                } else {
                    selected(nil)
                }
                return []
            case .ui(.retry):
                return [
                    supportedCurrenciesService.supportedCurrencies()
                        .map(Event.loadedSupportedCurrencies)
                        .catch { error in Just(.failed(error)) }
                        .eraseToAnyPublisher()
                ]
            }
        }
    }

    func sendAction(_ action: Event.UserAction) {
        input.send(.ui(action))
    }
}

struct CurrencyPairSelectorState {
    let disabled: [CurrencyPair]
    var currencies: [Currency] = []
    var first: Currency?
    var error: Swift.Error?

    var isSelectingSecond: Bool {
        first != nil
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
    }
}
