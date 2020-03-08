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
        let locale: Locale = Locale.current
        let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.decimal
            formatter.maximumFractionDigits = 4
            return formatter
        }()
    }

    init(viewModel: ViewModel, config: Config) {
        self.config = config
        super.init(viewModel: viewModel)
        config.numberFormatter.locale = config.locale
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
                actionImage: config.designLibrary.assets.plus,
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
        HostViewComponent(host: view, alignment: .fill) {
            TableViewComponent(sections: [
                [
                    AddCurrencyPairViewComponent(
                        bundle: self.config.bundle,
                        designLibrary: self.config.designLibrary,
                        isSelected: { if case .addingPair = state.status { return true } else { return false }}(),
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
        func formatAmount(_ amount: Decimal, minimumFractionDigits: Int = 0, label: String) -> String {
            config.numberFormatter.minimumFractionDigits = minimumFractionDigits
            return String.nonLeakingString(
                format: "rate_format",
                config.numberFormatter.string(for: amount) ?? "\(amount)",
                label
            )
        }
        let fromLocalizedDescription = NSLocalizedString(rate.pair.from.code, bundle: config.bundle, comment: "")
        let toLocalizedDescription = NSLocalizedString(rate.pair.to.code, bundle: config.bundle, comment: "")

        func accessibleFormat(rate: ExchangeRate) -> String {
            return String.nonLeakingString(
                format: "accessible_excahnge_rate_format",
                formatAmount(1, label: fromLocalizedDescription),
                formatAmount(rate.convert(amount: 1), minimumFractionDigits: 4, label: toLocalizedDescription)
            )
        }

        return ExchangeRateRowViewComponent(
            designLibrary: self.config.designLibrary,
            from: (
                amount: formatAmount(1, label: rate.pair.from.code),
                description: fromLocalizedDescription
            ),
            to: (
                amount: formatAmount(rate.convert(amount: 1), minimumFractionDigits: 4, label: rate.pair.to.code),
                description: toLocalizedDescription
            ),
            accessibilityLabel: accessibleFormat(rate: rate),
            onDelete: { sendAction(.deletePair(rate.pair)) },
            onRateUpdate: { update in
                state.observeUpdates(rate.pair) { rate in
                    update(
                        formatAmount(rate.convert(amount: 1), minimumFractionDigits: 4, label: rate.pair.to.code),
                        accessibleFormat(rate: rate)
                    )
                }
            }
        ).asAnyComponent()
    }
}

extension String {
    // There seem to be a bug related to leaking CFString when using String(format:args:)
    // At least memory graph debugger shows strings leaking
    // Workaround that by using NSString directly, this makes memory graph debugger happy
    // Might be also related to https://bugs.swift.org/browse/SR-4036
    static func nonLeakingString(format: String, _ args: CVarArg...) -> String {
        let result = withVaList(args) {
            NSString(format: NSLocalizedString(format as String, comment: ""), arguments: $0)
        }
        return "\(result)"
    }
}
