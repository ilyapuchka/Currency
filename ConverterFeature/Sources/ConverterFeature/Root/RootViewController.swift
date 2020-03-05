import UIKit
import DesignLibrary
import Future
import Domain

final class RootViewController<ViewModel: RootViewModelProtocol>: ViewModelViewController<ViewModel> {
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
        switch state.status {
        case .loading:
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
        state: RootState,
        sendAction: @escaping (RootEvent.UserAction) -> Void
    ) -> HostViewComponent<EmptyStateViewComponent> {
        HostViewComponent(host: view, alignment: .center) {
            EmptyStateViewComponent(
                bundle: config.bundle,
                designLibrary: config.designLibrary,
                action: { sendAction(.addPair) }
            )
        }
    }

    private func renderRates(
        state: RootState,
        sendAction: @escaping (RootEvent.UserAction) -> Void
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
        state: RootState,
        rate: ExchangeRate,
        sendAction: @escaping (RootEvent.UserAction) -> Void
    ) -> AnyComponent {
        func formatAmount(_ amount: Decimal, minimumFractionDigits: Int = 0, label: String) -> String {
            config.numberFormatter.minimumFractionDigits = minimumFractionDigits
            return String(
                format: NSLocalizedString("rate_format", comment: ""),
                config.numberFormatter.string(for: amount) ?? "\(amount)",
                label
            )
        }
        let fromLocalizedDescription = NSLocalizedString(rate.pair.from.code, bundle: config.bundle, comment: "")
        let toLocalizedDescription = NSLocalizedString(rate.pair.to.code, bundle: config.bundle, comment: "")

        func accessibleFormat(rate: ExchangeRate) -> String {
            String(
                format: NSLocalizedString("accessible_excahnge_rate_format", comment: ""),
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

