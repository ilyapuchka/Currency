import Foundation
import Domain
import Future

protocol RatesUpdateObserving {
    func start()
    func pause()
    func observeUpdates(pair: CurrencyPair, update: @escaping (ExchangeRate) -> Void) -> Void
    func update(_ future: @escaping () -> Future<[ExchangeRate], Error>)
    
    /**
     - returns: An observer object
     - parameters:
         - pair: a currency pair to observe for changes
         - update:a block to register as a notification handler
     */
    typealias AddObserver = (_ pair: CurrencyPair, _ update: @escaping (ExchangeRate) -> Void) -> Void
}

/// Periodically updates exchange rates and notifies observers
final class TimerRatesUpdateObserving: RatesUpdateObserving {
    private var observers: [CurrencyPair: (ExchangeRate) -> Void] = [:]

    /**
     Registers an observer for updates to provided currency pair exchange rates

     - parameters:
        - pair: a currency pair to observe for changes
        - update:a block to register as a notification handler
     */
    func observeUpdates(pair: CurrencyPair, update: @escaping (ExchangeRate) -> Void) -> Void {
        observers[pair] = update
    }

    private let updateTimer: Timer

    init(timer: Timer = Timer(repeatInterval: 1)) {
        updateTimer = timer
    }

    /// Pauses periodic updates
    func pause() {
        updateTimer.pause()
    }

    var isRunning: Bool {
        updateTimer.isRunning
    }

    /// Starts periodic updates
    func start() {
        updateTimer.start()
    }

    /// Sets a closure to run to update exchange rates. The closure should create a future value of updated exchange rates
    func update(_ future: @escaping () -> Future<[ExchangeRate], Error>) {
        updateTimer.observe { [unowned self] in
            future().on(success: { rates in
                rates.forEach { (rate) in
                    self.observers[rate.pair]?(rate)
                }
            })
        }
    }
}
