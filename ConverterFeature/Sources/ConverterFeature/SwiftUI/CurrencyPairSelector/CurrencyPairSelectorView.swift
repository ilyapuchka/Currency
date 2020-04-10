import SwiftUI
import DesignLibrary
import Domain
import Future

struct CurrencyPairSelectorView: View {
    @ObservedObject private var state: CurrencyPairSelectorViewState

    init(state: CurrencyPairSelectorViewState) {
        self.state = state
    }

    var body: some View {
        NavigationView {
            When(state.error,
                 then: { _ in self.error },
                 else: {
                    self.list
                        .push(isActive: self.state.isSelectingSecond) { self.list }
            })
        }
    }
    
    var error: some View {
        EmptyState(
            actionImage: nil,
            actionTitle: "retry",
            description: "failed_to_get_currency_list",
            action: { self.state.sendAction(.retry) }
        )
    }

    var list: some View {
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
}
