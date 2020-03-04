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
                    AddCurrencyPairButtonComponent(
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
        func formatAmount(_ amount: Decimal, minimumFractionDigits: Int = 0, currency: Currency) -> String {
            config.numberFormatter.minimumFractionDigits = minimumFractionDigits
            return String(
                format: NSLocalizedString("rate_format", comment: ""),
                config.numberFormatter.string(for: amount) ?? "\(amount)",
                currency.code
            )
        }
        return ExchangeRateRowViewComponent(
            designLibrary: self.config.designLibrary,
            from: (
                amount: formatAmount(1, currency: rate.pair.from),
                description: NSLocalizedString(rate.pair.from.code, bundle: config.bundle, comment: "")
            ),
            to: (
                amount: formatAmount(rate.convert(amount: 1), minimumFractionDigits: 4, currency: rate.pair.to),
                description: NSLocalizedString(rate.pair.to.code, bundle: config.bundle, comment: "")
            ),
            onDelete: { sendAction(.deletePair(rate.pair)) },
            onRateUpdate: { oldObserver, update in
                let addObserver = state.observeUpdates(rate.pair)
                return addObserver(oldObserver) { rate in
                    update(formatAmount(rate.convert(amount: 1), minimumFractionDigits: 4, currency: rate.pair.to))
                }
            }
        ).asAnyComponent()
    }
}

