import Foundation
import Domain
import Future

/// Periodically updates exchange rates and notifies observers
final class RatesUpdateObserving {
    private var observers: [CurrencyPair: (ExchangeRate) -> Void] = [:]

    /**
     - returns: An observer object
     - parameters:
         - pair: a currency pair to observe for changes
         - update:a block to register as a notification handler
     */
    typealias AddObserver = (_ pair: CurrencyPair, _ update: @escaping (ExchangeRate) -> Void) -> Void

    /**
     Registers an observer for updates to provided currency pair exchange rates

     - parameters:
        - pair: a currency pair to observe for changes
        - update:a block to register as a notification handler
     */
    func observeUpdates(pair: CurrencyPair, update: @escaping (ExchangeRate) -> Void) -> Void {
        observers[pair] = update
    }

    private let updateTimer = Timer(repeatInterval: 1)

    /// Pauses periodic updates
    func pause() {
        updateTimer.pause()
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
