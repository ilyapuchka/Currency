import SwiftUI
import Domain
import Future
import DesignLibrary

public struct RootView: View {
    struct State {
        var rates: [ExchangeRate] = []
        var pairs: [CurrencyPair] = []
        var error: Error?

        var status: Status

        var isAddingPair: Bool = false

        enum Status {
            case isLoading
            case isLoaded
            case addingPair(Promise<CurrencyPair?, Never>)
        }
    }

    @SwiftUI.State var state: State

    public init() {
        self._state = SwiftUI.State(initialValue:
            State(status: .isLoading)
        )
    }

    public var body: some View {
        When(state.error,
             then: { _ in
                EmptyState(
                    actionImage: nil,
                    actionTitle: "retry",
                    description: "failed_to_update",
                    action: {}
                )
             },
             else: {
                When(state.rates.isEmpty,
                     then: {
                        EmptyState(
                            actionImage: \.assets.plus,
                            actionTitle: "add_currency_pair_button_title",
                            description: "add_currency_pair_button_subtitle",
                            action: { self.state.isAddingPair = true }
                        ).sheet(
                            isPresented: self.$state.isAddingPair,
                            onDismiss: { self.state.isAddingPair = false }
                        ) {
                            CurrencyPairSelectorView() {
                                print($0, $1)
                                self.state.isAddingPair = false
                            }
                        }
                     },
                     else: {
                        Text("content")
                     }
                )
             }
        )
    }
}
