import SwiftUI
import DesignLibrary
import Domain
import Future

struct CurrencyPairSelectorView<State: ObservableViewState>: View
    where
    State.State == CurrencyPairSelectorState,
    State.Action == CurrencyPairSelectorEvent.UserAction {

    @ObservedObject private(set) var state: State

    var body: some View {
        CurrenciesList(
            items: state.currencies.map { currency in
                .init(
                    code: currency.code,
                    name: LocalizedStringKey(currency.code),
                    isEnabled: state.state.isEnabled(currency: currency)
                )
            },
            error: state.error,
            onRetry: { self.state.sendAction(.retry) }
        ) { value in
            let selected = self.state.currencies.first { $0.code == value.code }
            self.state.sendAction(.selected(selected!))
        }
    }
}
