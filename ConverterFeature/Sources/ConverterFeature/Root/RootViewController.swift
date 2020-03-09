import UIKit
import DesignLibrary
import Future
import Domain

final class RootViewController<ViewModel: ViewModelProtocol>: ViewModelViewController<ViewModel>
    where
    ViewModel.State == RootState,
    ViewModel.UserAction == RootEvent.UserAction {

    let config: Config

    struct Config {
        let bundle: Bundle
        let designLibrary: DesignLibrary
        var formatter: ExchangeRateFormatter
    }

    init(viewModel: ViewModel, config: Config) {
        self.config = config
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func render(state: ViewModel.State, sendAction: @escaping (ViewModel.UserAction) -> Void) -> [AnyComponent] {
        if state.error != nil {
            return [renderError(sendAction: sendAction).asAnyComponent()]
        }

        switch state.status {
        case .isLoading:
            return []
        case .addingPair, .isLoaded:
            return [
                state.rates.isEmpty
                    ? renderEmpty(state: state, sendAction: sendAction).asAnyComponent()
                    : renderRates(state: state, sendAction: sendAction).asAnyComponent()
            ]
        }
    }

    private func renderEmpty(
        state: ViewModel.State,
        sendAction: @escaping (ViewModel.UserAction) -> Void
    ) -> HostViewComponent<EmptyStateViewComponent> {
        HostViewComponent(host: view, alignment: .center) {
            EmptyStateViewComponent(
                bundle: config.bundle,
                designLibrary: config.designLibrary,
                actionImage: \DesignLibrary.assets.plus,
                actionTitle: NSLocalizedString("add_currency_pair_button_title", bundle: config.bundle, comment: ""),
                description: NSLocalizedString("add_currency_pair_button_subtitle", bundle: config.bundle, comment: ""),
                action: { sendAction(.addPair) }
            )
        }
    }

    private func renderError(
        sendAction: @escaping (ViewModel.UserAction) -> Void
    ) -> HostViewComponent<EmptyStateViewComponent> {
        HostViewComponent(host: view, alignment: .center) {
            EmptyStateViewComponent(
                bundle: config.bundle,
                designLibrary: config.designLibrary,
                actionImage: nil,
                actionTitle: NSLocalizedString("retry", bundle: config.bundle, comment: ""),
                description: NSLocalizedString("failed_to_update", bundle: config.bundle, comment: ""),
                action: { sendAction(.retry) }
            )
        }
    }

    private func renderRates(
        state: ViewModel.State,
        sendAction: @escaping (ViewModel.UserAction) -> Void
    ) -> HostViewComponent<TableViewComponent> {
        var addPairSelected: Bool
        if case .addingPair = state.status {
            addPairSelected = true
        } else {
            addPairSelected = false
        }

        return HostViewComponent(host: view, alignment: .fill) {
            TableViewComponent(sections: [
                [
                    AddCurrencyPairViewComponent(
                        bundle: self.config.bundle,
                        designLibrary: self.config.designLibrary,
                        isSelected: addPairSelected,
                        action: { sendAction(.addPair) }
                    ).asAnyComponent()
                ] + state.rates.map { rate in
                    renderExchangeRateRow(state: state, rate: rate, sendAction: sendAction)
                }
            ])
        }
    }

    func renderExchangeRateRow(
        state: ViewModel.State,
        rate: ExchangeRate,
        sendAction: @escaping (ViewModel.UserAction) -> Void
    ) -> AnyComponent {
        let fromLocalizedDescription = NSLocalizedString(rate.pair.from.code, bundle: config.bundle, comment: "")
        let toLocalizedDescription = NSLocalizedString(rate.pair.to.code, bundle: config.bundle, comment: "")

        return ExchangeRateViewComponent(
            designLibrary: self.config.designLibrary,
            from: (
                amount: config.formatter.formatFrom(rate: rate),
                description: fromLocalizedDescription
            ),
            to: (
                amount: config.formatter.formatTo(rate: rate),
                description: toLocalizedDescription
            ),
            accessibilityLabel: config.formatter.accessibleFormat(rate: rate),
            onDelete: { sendAction(.deletePair(rate.pair)) },
            onRateUpdate: { [formatter = config.formatter] update in
                state.observeUpdates(rate.pair) { rate in
                    update(
                        formatter.formatTo(rate: rate),
                        formatter.accessibleFormat(rate: rate)
                    )
                }
            }
        ).asAnyComponent()
    }
}
