import UIKit
import DesignLibrary
import DataAccess
import Future
import Domain
import Foundation

public struct ConverterFactory {
    let bundle: Bundle
    let designLibrary: DesignLibrary
    let selectedCurrencyPairsService: SelectedCurrencyPairsService
    let supportedCurrenciesService: SupportedCurrenciesService

    public init(
        bundle: Bundle,
        designLibrary: DesignLibrary,
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        supportedCurrenciesService: SupportedCurrenciesService
    ) {
        self.bundle = bundle
        self.designLibrary = designLibrary
        self.selectedCurrencyPairsService = selectedCurrencyPairsService
        self.supportedCurrenciesService = supportedCurrenciesService
    }

    public func makeRoot() -> UIViewController {
        let ratesService = RevolutExchangeRateService.init(session: URLSession.shared)
        let viewModel = RootViewModel(
            selectedCurrencyPairsService: selectedCurrencyPairsService,
            ratesService: ratesService,
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
