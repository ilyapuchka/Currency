import SwiftUI
import Future

struct CurrencyPairSelectorFlow<State: ObservableViewState>: View
    where
    State.State == CurrencyPairSelectorState,
    State.Action == CurrencyPairSelectorEvent.UserAction {

    let rootView: CurrencyPairSelectorView<State>
    @ObservedObject private(set) var state: State

    var body: some View {
        NavigationView {
            self.list
                .push(isActive: .constant(self.state.first != nil)) {
                    self.list
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear { self.state.sendAction(.dismiss) }
    }

    var list: some View {
        self.rootView
            .navigationBarHidden(true)
            .navigationBarTitle(Text(verbatim: ""))
    }
}
