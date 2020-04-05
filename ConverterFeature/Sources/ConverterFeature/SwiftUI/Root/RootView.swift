import SwiftUI
import Domain
import Future
import DesignLibrary

@dynamicMemberLookup
class RootViewState: ObservableObject {
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    @Published private(set) var state: State

    let supportedCurrenciesService: SupportedCurrenciesService
    let formatter: ExchangeRateFormatter

    init(
        initial: State = .init(),
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        supportedCurrenciesService: SupportedCurrenciesService,
        ratesService: ExchangeRateService,
        //ratesObserving: RatesUpdateObserving,
        formatter: ExchangeRateFormatter
    ) {
        self.supportedCurrenciesService = supportedCurrenciesService
        self.formatter = formatter

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
            case .initialised:
                return [
                    selectedCurrencyPairsService
                        .selectedCurrencyPairs()
                        .catch { _ in Just([]) }
                        .flatMap { (pairs: [CurrencyPair]) -> AnyPublisher<Event, Never> in
                            pairs.isEmpty
                                ? Just(Event.loadedRates([])).eraseToAnyPublisher()
                                : ratesService.exchangeRates(pairs: pairs)
                                    .map(Event.loadedRates)
                                    .catch { error in Just(Event.failedToGetRates(pairs, error)) }
                                    .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
                ]
            case let .loadedRates(rates):
                state.rates = rates
                state.pairs = rates.map { $0.pair }
                state.error = nil

                state.status = .isLoaded
                return []
            case let .updatedRates(rates):
                guard !rates.isEmpty else { return [] }

                state.rates = rates
                state.pairs = rates.map { $0.pair }
                state.error = nil
                //ratesObserving.start()
                state.status = .isLoaded

                return []

            case .ui(.addPair):
                state.status = .addingPair
                return []
            case let .ui(.added(pair)):
                state.status = .isLoaded

                guard let pair = pair else {
                    return []
                }
                
                state.pairs.insert(pair, at: 0)

                return [
                    selectedCurrencyPairsService
                        .save(selectedPairs: state.pairs)
                        .flatMap { _ in Empty<Event, Error>() }
                        .catch { _ in Empty<Event, Never>() }
                        .eraseToAnyPublisher(),
                    ratesService
                        .exchangeRates(pairs: state.pairs)
                        .map(Event.updatedRates)
                        // We could display alert when update fails, for now just ignore errors here,
                        // they will be recovered on restart
                        .catch { [rates = state.rates] _ in Just(Event.updatedRates(rates)) }
                        .eraseToAnyPublisher(),
                ]

            case let .ui(.deletePair(removed)):
                state.pairs.remove(atOffsets: removed)
                state.rates.remove(atOffsets: removed)

                return [
                    selectedCurrencyPairsService
                        .save(selectedPairs: state.pairs)
                        .flatMap { _ in Empty<Event, Error>() }
                        .catch { _ in Empty<Event, Never>() }
                        .eraseToAnyPublisher()
                ]
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
            if case .addingPair = status { return true }
            else { return false }
        }

        enum Status {
            case isLoading
            case isLoaded
            case addingPair
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
            case deletePair(IndexSet)
            case retry
        }
    }
}

public struct RootView: View {
    @ObservedObject private var state: RootViewState

    public init(
        selectedCurrencyPairsService: SelectedCurrencyPairsService,
        supportedCurrenciesService: SupportedCurrenciesService,
        ratesService: ExchangeRateService,
        formatter: ExchangeRateFormatter
    ) {
        self.state = RootViewState(
            selectedCurrencyPairsService: selectedCurrencyPairsService,
            supportedCurrenciesService: supportedCurrenciesService,
            ratesService: ratesService,
            formatter: formatter
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
                        )
                     },
                     else: {
                        ExchangeRatesList(
                            items: state.rates.map { rate in
                                ExchangeRatesList.Item(
                                    id: "\(rate.pair.hashValue)",
                                    from: (amount: state.formatter.formatFrom(rate: rate), description: rate.pair.from.code),
                                    to: (amount: state.formatter.formatTo(rate: rate), description: rate.pair.to.code)
                                )
                            },
                            onAdd: { self.state.sendAction(.addPair) },
                            onDelete: { self.state.sendAction(.deletePair($0)) }
                        )
                    }
                ).sheet(isPresented: $state.isAddingPair) {
                    CurrencyPairSelectorView(
                        supportedCurrenciesService: self.state.supportedCurrenciesService,
                        disabled: self.state.pairs,
                        selected: { self.state.sendAction(.added($0)) }
                    )
                }
             }
        )
    }
}
