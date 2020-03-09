import UIKit
import DesignLibrary
import Future
import Domain

final class CurrencyPairSelectorViewController<ViewModel: ViewModelProtocol>:
    ViewModelViewController<ViewModel>,
    UIAdaptivePresentationControllerDelegate
    where
    ViewModel.State == CurrencyPairSelectorState,
    ViewModel.UserAction == CurrencyPairSelectorEvent.UserAction {

    let config: Config

    struct Config {
        let bundle: Bundle
        let designLibrary: DesignLibrary
        let onDismiss: Promise<Void, Never>
    }

    init(viewModel: ViewModel, config: Config) {
        self.config = config
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        config.onDismiss.fulfill(.success(()))
    }

    override func render(state: ViewModel.State, sendAction: @escaping (ViewModel.UserAction) -> Void) -> [AnyComponent] {
        guard state.error == nil else {
            return [
                HostViewComponent(host: view, alignment: .center) {
                    EmptyStateViewComponent(
                        bundle: config.bundle,
                        designLibrary: config.designLibrary,
                        actionImage: nil,
                        actionTitle: NSLocalizedString("retry", bundle: config.bundle, comment: ""),
                        description: NSLocalizedString("failed_to_get_currency_list", bundle: config.bundle, comment: ""),
                        action: { sendAction(.retry) })
                }.asAnyComponent()
            ]
        }

        return [
            HostViewComponent(host: view, alignment: .fill) {
                TableViewComponent(sections: [
                    state.supported.map { currency in
                        CurrencyViewComponent(
                            designLibrary: config.designLibrary,
                            image: UIImage(named: currency.code, in: config.bundle, compatibleWith: nil),
                            code: currency.code,
                            name: NSLocalizedString(currency.code, bundle: config.bundle, comment: ""),
                            isEnabled: state.isEnabled(currency: currency),
                            action: { sendAction(.selected(currency)) }
                        ).asAnyComponent()
                    }
                ])
            }.asAnyComponent()
        ]
    }
}
