import SwiftUI
import Domain
import Future
import DesignLibrary
import Combine

class RootViewState: StateMachine {
    @Published var state: State
    let reduce: Reducer

    init(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService//,
        //ratesObserving: RatesUpdateObserving
    ) {
        state = .init()
        reduce = Self.reduce(
            selectedCurrencyPairsService: selectedCurrencyPairsService,
            ratesService: ratesService//,
            //ratesObserving: ratesObserving
        )
        sink(event: .initialised)
    }

    func sendAction(_ action: Event.UserAction) {
        sink(event: .ui(action))
    }

    static func reduce(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService//,
        //ratesObserving: RatesUpdateObserving
    ) -> Reducer {
        return { state, event in
            switch event {
            case .ui(.addPair):
                state.status = .addingPair
                return []
            default:
                state.status = .isLoaded
                return []
            }
        }
    }

    struct State {
        var rates: [ExchangeRate] = []
        var pairs: [CurrencyPair] = []
        var error: Error?

        var status: Status = .isLoading

        var isAddingPair: Bool {
            get {
                if case .addingPair = status { return true }
                else { return false }
            }
        }

        enum Status {
            case isLoading
            case isLoaded
            case addingPair/*(Promise<CurrencyPair?, Never>)*/
        }
    }

    enum Event {
        case initialised
        /// Got rates for previously selected pairs
        case loadedRates([ExchangeRate])
        /// Failed to get exchange rates for previously selected pairs
        case failedToGetRates([CurrencyPair], Error)
        /// Updated exchange rates
        case updatedRates([ExchangeRate])
        case ui(UserAction)

        enum UserAction {
            case addPair
            /// Added a pair or canceled selection if nil
            case added(CurrencyPair?)
            case deletePair(CurrencyPair)
            case retry
        }
    }
}

public struct RootView: View {
    @ObservedObject private var state: RootViewState

    public init(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService
    ) {
        self.state = RootViewState(
            selectedCurrencyPairsService: selectedCurrencyPairsService,
            ratesService: ratesService
        )
    }

    public var body: some View {
        When(state.state.error,
             then: { _ in
                EmptyState(
                    actionImage: nil,
                    actionTitle: "retry",
                    description: "failed_to_update",
                    action: {}
                )
             },
             else: {
                When(state.rates.isEmpty,
                     then: {
                        EmptyState(
                            actionImage: \.assets.plus,
                            actionTitle: "add_currency_pair_button_title",
                            description: "add_currency_pair_button_subtitle",
                            action: {
                                self.state.sendAction(.addPair)
                            }
                        ).sheet(
                            isPresented: $state.isAddingPair,
                            onDismiss: {
                                self.state.sendAction(.added(nil))
                            }
                        ) {
                            CurrencyPairSelectorView() {
                                self.state.sendAction(.added($0))
                            }
                        }
                     },
                     else: {
                        EmptyView.init()
                        //Text("content")
                     }
                )
             }
        )
    }
}
