import UIKit
import DesignLibrary
import Future
import Domain

final class RootViewController<ViewModel: RootViewModelProtocol>: ViewModelViewController<ViewModel> {
    let config: Config

    struct Config {
        let bundle: Bundle
        let designLibrary: DesignLibrary
    }

    init(viewModel: ViewModel, config: Config) {
        self.config = config
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func render(state: ViewModel.State, sendAction: @escaping (ViewModel.UserAction) -> Void) -> [AnyComponent] {
        switch state.status {
        case .loading:
            return []
        case .addingPair:
            return state.rates.isEmpty
                ? renderEmpty(state: state, sendAction: sendAction)
                : renderRates(state: state, sendAction: sendAction)
        case .isLoaded:
            return state.rates.isEmpty
                ? renderEmpty(state: state, sendAction: sendAction)
                : renderRates(state: state, sendAction: sendAction)
        }
    }

    private func renderEmpty(state: RootState, sendAction: @escaping (RootEvent.UserAction) -> Void) -> [AnyComponent] {
        return [
            HostViewComponent(host: view, alignment: .center) {
                EmptyStateViewComponent(
                    bundle: config.bundle,
                    designLibrary: config.designLibrary,
                    action: { sendAction(.addPair) }
                ).asAnyComponent()
            }.asAnyComponent()
        ]
    }

    private func renderRates(state: RootState, sendAction: @escaping (RootEvent.UserAction) -> Void) -> [AnyComponent] {
        return [
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
                ]).asAnyComponent()
            }.asAnyComponent()
        ]
    }

    func renderExchangeRateRow(state: RootState, rate: ExchangeRate, sendAction: @escaping (RootEvent.UserAction) -> Void) -> AnyComponent {
        func formatAmount(_ amount: Decimal, currency: Currency) -> String {
            "\(amount) \(currency.code)"
        }
        return ExchangeRateRowViewComponent(
            designLibrary: self.config.designLibrary,
            from: (amount: formatAmount(1, currency: rate.pair.from), description: rate.pair.from.code),
            to: (amount: formatAmount(rate.convert(amount: 1), currency: rate.pair.to), description: rate.pair.to.code),
            onDelete: { sendAction(.deletePair(rate.pair)) },
            onRateUpdate: { update in
                let observer = state.rateUpdatesObserver(rate.pair)
                observer { rate in
                    update(formatAmount(rate.convert(amount: 1), currency: rate.pair.to))
                }
            }
        ).asAnyComponent()
    }
}

