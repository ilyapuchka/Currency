import SwiftUI
import Domain
import Future
import DesignLibrary

struct RootView: View {
    @ObservedObject private var state: RootViewState

    init(state: RootViewState) {
        self.state = state
    }

    public var body: some View {
        When(state.error,
             then: { _ in self.error },
             else: {
                When(state.rates.isEmpty,
                     then: { self.empty },
                     else: { self.exchangeRates }
                ).sheet(isPresented: self.state.isAddingPair) {
                    CurrencyPairSelectorView(
                        state: CurrencyPairSelectorViewState(
                            disabled: self.state.pairs,
                            selected: { self.state.sendAction(.added($0)) },
                            supportedCurrenciesService: self.state.supportedCurrenciesService
                        )
                    ).onDisappear {
                        self.state.sendAction(.added(nil))
                    }
                }
             }
        )
    }

    var empty: some View {
        EmptyState(
            actionImage: \.assets.plus,
            actionTitle: "add_currency_pair_button_title",
            description: "add_currency_pair_button_subtitle",
            action: { self.state.sendAction(.addPair) }
        )
    }

    var error: some View {
        EmptyState(
            actionImage: nil,
            actionTitle: "retry",
            description: "failed_to_update",
            action: { self.state.sendAction(.retry) }
        )
    }

    var exchangeRates: some View {
        ExchangeRatesList(
            items: state.rates.map { rate in
                ExchangeRatesList.Item(
                    id: rate.pair.hashValue,
                    from: (amount: state.formatter.formatFrom(rate: rate), description: rate.pair.from.code),
                    to: (amount: state.formatter.formatTo(rate: rate), description: rate.pair.to.code)
                )
            },
            onAdd: { self.state.sendAction(.addPair) },
            onDelete: { self.state.sendAction(.deletePair($0)) }
        )
    }
}
