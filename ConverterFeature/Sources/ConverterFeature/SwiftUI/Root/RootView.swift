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

        var route: Route?

        var isAddingPair: Bool {
            get {
                switch route {
                case .addPair:
                    return true
                default:
                    return false
                }
            }
            set {
                route = newValue ? .addPair : nil
            }
        }

        enum Status {
            case isLoading
            case isLoaded
            case addingPair(Promise<CurrencyPair?, Never>)
        }

        enum Route {
            case addPair
        }
    }

    @SwiftUI.State var state: State
    let bundle: Bundle

    public init(
        bundle: Bundle
    ) {
        self.bundle = bundle
        self._state = SwiftUI.State(initialValue:
            State(status: .isLoading)
        )
    }

    public var body: some View {
        When(state.error,
             then: { _ in
                EmptyStateViewSwiftUI(
                    actionImage: nil,
                    actionTitle: NSLocalizedString("retry", bundle: bundle, comment: ""),
                    description: NSLocalizedString("failed_to_update", bundle: bundle, comment: ""),
                    action: {},
                    bundle: bundle
                )
             },
             else: {
                When(state.rates.isEmpty,
                     then: {
                            EmptyStateViewSwiftUI(
                                actionImage: \.assets.plus,
                                actionTitle: NSLocalizedString("add_currency_pair_button_title", bundle: bundle, comment: ""),
                                description: NSLocalizedString("add_currency_pair_button_subtitle", bundle: bundle, comment: ""),
                                action: { self.state.isAddingPair = true },
                                bundle: bundle
                            ).sheet(
                                isPresented: self.$state.isAddingPair,
                                onDismiss: { self.state.isAddingPair = false }) {
                                    NavigationView {
                                        CurrenciesList(
                                            items: [Currency](["EUR", "USD"]).map { currency in
                                                .init(
                                                    code: currency.code,
                                                    name: NSLocalizedString(currency.code, bundle: self.bundle, comment: ""),
                                                    isEnabled: true
                                                )
                                            },
                                            bundle: self.bundle
                                        ) { _ in
                                            CurrenciesList(
                                                items: [Currency](["EUR", "USD"]).map { currency in
                                                    .init(
                                                        code: currency.code,
                                                        name: NSLocalizedString(currency.code, bundle: self.bundle, comment: ""),
                                                        isEnabled: true
                                                    )
                                                },
                                                bundle: self.bundle
                                            )
                                        }
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
