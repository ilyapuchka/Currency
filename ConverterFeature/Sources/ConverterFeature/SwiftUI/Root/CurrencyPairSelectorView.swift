import SwiftUI
import DesignLibrary
import Domain

struct CurrencyPairSelectorView: View {
    struct State {
        var first: Int?

        var isSelectingSecond: Bool {
            get { first != nil }
            set { }
        }
    }

    @SwiftUI.State var state: State
    var selected: (Int, Int) -> Void

    init(selected: @escaping (Int, Int) -> Void) {
        self.selected = selected
        self._state = SwiftUI.State(initialValue:
            State()
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
                self.state.first = index
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
                    self.selected(self.state.first!, index)
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
