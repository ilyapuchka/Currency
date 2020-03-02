import UIKit
import DesignLibrary
import Future
import Domain

final class CurrencyPairSelectorViewController<ViewModel: CurrencyPairSelectorViewModelProtocol>: ViewModelViewController<ViewModel>, UIAdaptivePresentationControllerDelegate {
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
        return [
            HostViewComponent(host: view, alignment: .fill) {
                TableViewComponent(sections: [
                    state.supported.map { currency in
                        CurrencyRowViewComponent(
                            designLibrary: config.designLibrary,
                            image: UIImage(named: currency.code, in: config.bundle, compatibleWith: nil),
                            code: currency.code,
                            name: currency.code,
                            action: { sendAction(.selected(currency)) }
                        ).asAnyComponent()
                    }
                ]).asAnyComponent()
            }.asAnyComponent()
        ]
    }
}