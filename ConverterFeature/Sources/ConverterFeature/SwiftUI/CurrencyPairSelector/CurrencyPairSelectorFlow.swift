import SwiftUI

struct CurrencyPairSelectorFlow<State: ObservableViewState>: View
    where
    State.State == CurrencyPairSelectorState,
    State.Action == CurrencyPairSelectorEvent.UserAction {

    let rootView: CurrencyPairSelectorView<State>
    @ObservedObject var state: State

    var body: some View {
        NavigationView {
            self.list
                .push(isActive: { self.state.first != nil }) {
                    self.list
                }
        }.onDisappear {
            self.state.sendAction(.dismiss)
        }
    }

    var list: some View {
        self.rootView
            .navigationBarHidden(true)
            .navigationBarTitle(Text(verbatim: ""))
    }
}
