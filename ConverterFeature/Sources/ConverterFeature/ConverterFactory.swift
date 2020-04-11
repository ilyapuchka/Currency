import UIKit
import DesignLibrary
import Future
import Domain
import Foundation
import SwiftUI

public struct ConverterFactory {
    let selectedCurrencyPairsService: SelectedCurrencyPairsService
    let supportedCurrenciesService: SupportedCurrenciesService
    let exchangeRatesService: ExchangeRateService

    public init(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        supportedCurrenciesService: SupportedCurrenciesService,
        exchangeRatesService: ExchangeRateService
    ) {
        self.selectedCurrencyPairsService = selectedCurrencyPairsService
        self.supportedCurrenciesService = supportedCurrenciesService
        self.exchangeRatesService = exchangeRatesService
    }

    public func makeRoot() -> some View {
        let view = RootView<RootViewState>(
            state: .init(
                selectedCurrencyPairsService: selectedCurrencyPairsService,
                ratesService: exchangeRatesService,
                ratesObserving: TimerRatesUpdateObserving()
            ),
            formatter: LocalizedExchangeRateFormatter()
        )

        return RootFlow(
            rootView: view,
            state: view.state,
            selectPair: { disabled, selected in
                AnyView(
                    self.makeSelectPair(disabled: disabled, selected: selected)
                )
            }
        )
    }

    public func makeSelectPair(
        disabled: [CurrencyPair],
        selected: @escaping (CurrencyPair?) -> Void
    ) -> some View {
        let view = CurrencyPairSelectorView<CurrencyPairSelectorViewState>(
            state: .init(
                disabled: disabled,
                selected: selected,
                supportedCurrenciesService: supportedCurrenciesService
            )
        )
        
        return CurrencyPairSelectorFlow(
            rootView: view,
            state: view.state
        )
    }
}
