import SwiftUI
import DesignLibrary
import Domain
import Future

class CurrencyPairSelectorViewState: StateMachine {
    @Published var state: State
    let reduce: Reducer

    init(selected: @escaping (CurrencyPair) -> Void) {
        self.state = State(first: nil)
        self.reduce = Self.reduce(selected: selected)
    }

    struct State {
        var first: Currency?

        var isSelectingSecond: Bool {
            first != nil
        }
    }

    static func reduce(
        selected: @escaping (CurrencyPair) -> Void
    ) -> Reducer {
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
        sink(event: .ui(action))
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
