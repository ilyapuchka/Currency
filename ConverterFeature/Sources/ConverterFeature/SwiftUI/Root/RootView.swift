import SwiftUI
import Domain
import Future
import DesignLibrary
import Combine

@dynamicMemberLookup
class RootViewState: ObservableObject {
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    @Published private(set) var state: State

    let supportedCurrenciesService: SupportedCurrenciesService

    init(
        initial: State = .init(),
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        supportedCurrenciesService: SupportedCurrenciesService,
        ratesService: ExchangeRateService//,
        //ratesObserving: RatesUpdateObserving
    ) {
        self.supportedCurrenciesService = supportedCurrenciesService
        state = initial
        StateMachine.make(
            assignTo: \.state,
            on: self,
            input: input.sink,
            reduce: Self.reduce(
                selectedCurrencyPairsService: selectedCurrencyPairsService,
                ratesService: ratesService
            )
        ).store(in: &bag)
        input.send(.initialised)
    }

    func sendAction(_ action: Event.UserAction) {
        input.send(.ui(action))
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
        set {}
    }

    static func reduce(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        ratesService: ExchangeRateService//,
        //ratesObserving: RatesUpdateObserving
    ) -> Reducer<State, Event> {
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
        supportedCurrenciesService: SupportedCurrenciesService,
        ratesService: ExchangeRateService
    ) {
        self.state = RootViewState(
            selectedCurrencyPairsService: selectedCurrencyPairsService,
            supportedCurrenciesService: supportedCurrenciesService,
            ratesService: ratesService
        )
    }

    public var body: some View {
        When(state.error,
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
                            CurrencyPairSelectorView(
                                supportedCurrenciesService: self.state.supportedCurrenciesService
                            ) {
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
