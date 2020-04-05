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
        initial: State,
        selected: @escaping (CurrencyPair) -> Void
    ) {
        state = initial
        StateMachine.make(
            assignTo: \.state,
            on: self,
            input: input.sink,
            reduce: Self.reduce(selected: selected)
        ).store(in: &bag)
    }

    struct State {
        var first: Currency? = nil

        var isSelectingSecond: Bool {
            first != nil
        }
    }

    static func reduce(
        selected: @escaping (CurrencyPair) -> Void
    ) -> Reducer<State, Event> {
        return { state, event in
            switch event {
            case let .ui(.selected(currency)):
                if let first = state.first {
                    selected(CurrencyPair(from: first, to: currency))
                } else {
                    state.first = currency
                }
                return []
            default:
                return []
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
            case selected(Currency)
            case retry
        }
    }
}

struct CurrencyPairSelectorView: View {
    @ObservedObject private var state: CurrencyPairSelectorViewState

    init(selected: @escaping (CurrencyPair) -> Void) {
        self.state = CurrencyPairSelectorViewState(
            initial: .init(),
            selected: selected
        )
    }

    var body: some View {
        NavigationView {
            CurrenciesList(
                items: [Currency](["EUR", "USD"]).map { currency in
                    .init(
                        code: currency.code,
                        name: LocalizedStringKey(currency.code),
                        isEnabled: true
                    )
                }
            ) { index in
                self.state.sendAction(.selected("EUR"))
            }
            .push(isActive: self.$state.isSelectingSecond) {
                CurrenciesList(
                    items: [Currency](["EUR", "USD"]).map { currency in
                        .init(
                            code: currency.code,
                            name: LocalizedStringKey(currency.code),
                            isEnabled: true
                        )
                    }
                ) { index in
                    self.state.sendAction(.selected("USD"))
                }
            }
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
