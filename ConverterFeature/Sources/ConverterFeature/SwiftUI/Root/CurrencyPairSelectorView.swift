import SwiftUI
import DesignLibrary
import Domain
import Future

@dynamicMemberLookup
class CurrencyPairSelectorViewState: ObservableObject {
    private var bag = Set<AnyCancellable>()

    deinit {
        print("deinit")
    }

    private let input = PassthroughSubject<Event, Never>()
    @Published private(set) var state: State

    init(
        supportedCurrenciesService: SupportedCurrenciesService,
        disabled: [CurrencyPair],
        selected: @escaping (CurrencyPair?) -> Void
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

    struct State {
        let disabled: [CurrencyPair]
        var currencies: [Currency] = []
        var first: Currency?
        var error: Swift.Error?

        var isSelectingSecond: Bool {
            first != nil
        }
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

    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
        set {}
    }

    enum Event {
        case initialised
        case loadedSupportedCurrencies([Currency])
        case failed(Error)
        case ui(UserAction)

        enum UserAction {
            case selected(Currency?)
            case retry
        }
    }
}

struct CurrencyPairSelectorView: View {
    @ObservedObject private var state: CurrencyPairSelectorViewState

    init(
        supportedCurrenciesService: SupportedCurrenciesService,
        disabled: [CurrencyPair],
        selected: @escaping (CurrencyPair?) -> Void
    ) {
        self.state = CurrencyPairSelectorViewState(
            supportedCurrenciesService: supportedCurrenciesService,
            disabled: disabled,
            selected: selected
        )
    }

    var body: some View {
        NavigationView {
            When(state.error,
                 then: { _ in
                    EmptyState(
                        actionImage: nil,
                        actionTitle: "retry",
                        description: "failed_to_get_currency_list",
                        action: {
                            self.state.sendAction(.retry)
                        }
                    )
            },
                 else: {
                    CurrenciesList(
                        items: state.currencies.map { currency in
                            .init(
                                code: currency.code,
                                name: LocalizedStringKey(currency.code),
                                isEnabled: state.isEnabled(currency: currency)
                            )
                        }
                    ) { value in
                        let selected = self.state.currencies.first { $0.code == value.code }
                        self.state.sendAction(.selected(selected!))
                    }
                    .push(isActive: self.$state.isSelectingSecond) {
                        CurrenciesList(
                            items: state.currencies.map { currency in
                                .init(
                                    code: currency.code,
                                    name: LocalizedStringKey(currency.code),
                                    isEnabled: state.isEnabled(currency: currency)
                                )
                            }
                        ) { value in
                            let selected = self.state.currencies.first { $0.code == value.code }
                            self.state.sendAction(.selected(selected!))
                        }
                    }
            })
        }.onDisappear {
            self.state.sendAction(.selected(nil))
        }
    }
}

extension View {
    func push<V: View>(isActive: Binding<Bool>, @ViewBuilder destination: () -> V) -> some View {
        ZStack {
            self
            NavigationLink(
                destination: destination(),
                isActive: isActive,
                label: { SwiftUI.EmptyView() }
            )
        }
    }
}
