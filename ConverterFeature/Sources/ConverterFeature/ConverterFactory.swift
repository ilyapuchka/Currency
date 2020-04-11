import UIKit
import DesignLibrary
import Future
import Domain
import Foundation

#if canImport(SwiftUI)
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
#else
public struct ConverterFactory {
    let bundle: Bundle
    let designLibrary: DesignLibrary
    let selectedCurrencyPairsService: SelectedCurrencyPairsService
    let supportedCurrenciesService: SupportedCurrenciesService
    let exchangeRatesService: ExchangeRateService

    public init(
        bundle: Bundle,
        designLibrary: DesignLibrary,
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        supportedCurrenciesService: SupportedCurrenciesService,
        exchangeRatesService: ExchangeRateService
    ) {
        self.bundle = bundle
        self.designLibrary = designLibrary
        self.selectedCurrencyPairsService = selectedCurrencyPairsService
        self.supportedCurrenciesService = supportedCurrenciesService
        self.exchangeRatesService = exchangeRatesService
    }

    public func makeRoot() -> UIViewController {
        let viewModel = RootViewModel(
            selectedCurrencyPairsService: selectedCurrencyPairsService,
            ratesService: exchangeRatesService,
            ratesObserving: TimerRatesUpdateObserving()
        )

        let viewController = RootViewController(
            viewModel: viewModel,
            config: .init(
                bundle: bundle,
                designLibrary: designLibrary,
                formatter: LocalizedExchangeRateFormatter(bundle: bundle)
            )
        )

        let flowController = RootFlowController(
            modal: viewController,
            addPair: makeSelectFirstCurrency
        )

        viewModel.addPair(flowController.addPair)

        return viewController
    }

    public func makeSelectFirstCurrency(disabled: [CurrencyPair], selected: Promise<CurrencyPair?, Never>) -> UIViewController {
        let viewModel = CurrencyPairSelectorViewModel(
            disabled: disabled,
            selected: selected,
            supportedCurrenciesService: supportedCurrenciesService
        )

        let onDismiss = Promise<Void, Never>()
        onDismiss.observe { _ in
            selected.fulfill(.success(nil))
        }

        let viewController = CurrencyPairSelectorViewController(
            viewModel: viewModel,
            config: .init(
                bundle: bundle,
                designLibrary: designLibrary,
                onDismiss: onDismiss
            )
        )
        let navigation = UINavigationController(rootViewController: viewController)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.presentationController?.delegate = viewController

        let flowController = CurrencyPairSelectorFlowController(
            navigation: navigation,
            makeSecond: makeSelectSecondCurrency
        )
        viewModel.selectedFirst(flowController.selectSecond)

        return navigation
    }

    public func makeSelectSecondCurrency(first: Currency, disabled: [CurrencyPair], selected: Promise<CurrencyPair?, Never>) -> UIViewController {
        let viewModel = CurrencyPairSelectorViewModel(
            first: first,
            disabled: disabled,
            selected: selected,
            supportedCurrenciesService: supportedCurrenciesService
        )

        let onDismiss = Promise<Void, Never>()
        onDismiss.observe { _ in
            selected.fulfill(.success(nil))
        }

        let viewController = CurrencyPairSelectorViewController(
            viewModel: viewModel,
            config: .init(
                bundle: bundle,
                designLibrary: designLibrary,
                onDismiss: onDismiss
            )
        )
        return viewController
    }
}
#endif
