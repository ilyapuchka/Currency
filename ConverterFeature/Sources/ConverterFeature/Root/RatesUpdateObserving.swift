import Foundation
import Domain
import Future

public protocol RatesUpdateObserving {
    func start()
    func pause()

    /// Sets a closure to run to update exchange rates. The closure should create a future value of updated exchange rates
    #if canImport(Combine)
    func update<S: Subscriber>(
        subscriber: S,
        _ future: @escaping () -> AnyPublisher<[ExchangeRate], Error>
    ) where S.Input == [ExchangeRate], S.Failure == Never
    #else
    /**
     Registers an observer for updates to provided currency pair exchange rates

     - parameters:
     - pair: a currency pair to observe for changes
     - update:a block to register as a notification handler
     */
    func observeUpdates(pair: CurrencyPair, update: @escaping (ExchangeRate) -> Void) -> Void

    func update(_ future: @escaping () -> Future<[ExchangeRate], Error>)
    #endif
    /**
     - returns: An observer object
     - parameters:
         - pair: a currency pair to observe for changes
         - update:a block to register as a notification handler
     */
    typealias AddObserver = (_ pair: CurrencyPair, _ update: @escaping (ExchangeRate) -> Void) -> Void
}

/// Periodically updates exchange rates and notifies observers
public final class TimerRatesUpdateObserving: RatesUpdateObserving {
    private var observers: [CurrencyPair: (ExchangeRate) -> Void] = [:]

    #if canImport(Combine)
    var bag = Set<AnyCancellable>()
    #endif

    private let updateTimer: Timer

    public init(timer: Timer = Timer(repeatInterval: 1)) {
        updateTimer = timer
    }

    /// Pauses periodic updates
    public func pause() {
        updateTimer.pause()
    }

    public var isRunning: Bool {
        updateTimer.isRunning
    }

    /// Starts periodic updates
    public func start() {
        updateTimer.start()
    }

    #if canImport(Combine)
    public func update<S: Subscriber>(
        subscriber: S,
        _ future: @escaping () -> AnyPublisher<[ExchangeRate], Error>
    ) where S.Input == [ExchangeRate], S.Failure == Never {
        let subject = PassthroughSubject<[ExchangeRate], Never>()
        subject.receive(on: DispatchQueue.main).receive(subscriber: subscriber)

        updateTimer.observe { [unowned self] in
            future()
                .catch { _ in Empty() }
                .sink { subject.send($0) }
                .store(in: &self.bag)
        }
    }
    #else
    public func observeUpdates(pair: CurrencyPair, update: @escaping (ExchangeRate) -> Void) -> Void {
        observers[pair] = update
    }

    public func update(_ future: @escaping () -> Future<[ExchangeRate], Error>) {
        updateTimer.observe { [unowned self] in
            future().on(success: { rates in
                rates.forEach { (rate) in
                    self.observers[rate.pair]?(rate)
                }
            })
        }
    }
    #endif
}
