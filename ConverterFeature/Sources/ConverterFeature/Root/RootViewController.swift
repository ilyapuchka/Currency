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
        var rows = state.rates.map { rate -> AnyComponent in
            return ExchangeRateRowViewComponent(
                designLibrary: self.config.designLibrary,
                from: (amount: "1 \(rate.pair.from.code)", name: rate.pair.from.code),
                to: (amount: "\(rate.convert(amount: 1)) \(rate.pair.to.code)", name: rate.pair.to.code),
                onDelete: { sendAction(.deletePair(rate.pair)) },
                onUpdate: { update in
                    state.observeRateUpdate(pair: rate.pair) { rate in
                        update("\(rate.convert(amount: 1)) \(rate.pair.to.code)")
                    }
                }
            ).asAnyComponent()
        }
        rows.insert(
            AddCurrencyPairButtonComponent(
                bundle: self.config.bundle,
                designLibrary: self.config.designLibrary,
                isSelected: { if case .addingPair = state.status { return true } else { return false }}(),
                action: { sendAction(.addPair) }
            ).asAnyComponent(),
            at: 0
        )
        return [
            HostViewComponent(host: view, alignment: .fill) {
                TableViewComponent(sections: [rows]).asAnyComponent()
            }.asAnyComponent()
        ]
    }
}

