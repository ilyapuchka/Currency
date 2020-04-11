import SwiftUI
import Domain

struct RootFlow<State: ObservableViewState>: View
    where
    State.State == RootState,
    State.Action == RootEvent.UserAction {

    let rootView: RootView<State>
    @ObservedObject private(set) var state: State

    typealias SelectPair = (
        _ disabled: [CurrencyPair],
        _ selected: @escaping (CurrencyPair?) -> Void
    ) -> AnyView

    let selectPair: SelectPair

    var body: some View {
        rootView
            .modal(isPresented: self.state.isAddingPair) {
                self.selectPair(self.state.pairs) {
                    self.state.sendAction(.added($0))
                }
        }
    }
}
