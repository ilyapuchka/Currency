import Foundation
import Domain
import Future

/// Periodically updates of exchange rates and notifies observers
struct RatesUpdateObserving {
    static let notificationName = NSNotification.Name("ratesUpdated")

    /**
     Register observer for rate updates notifications

     - returns: An observer object
     - parameters:
         - oldObserver: an observer to unregister from notifications
         - update:a block to register as a notification handler
     */
    typealias AddObserver = (_ oldObserver: Any?, _ update: @escaping (ExchangeRate) -> Void) -> Any

    /// Creates a function to register observer for updates to provided currency pair
    func observeUpdates(_ pair: CurrencyPair) -> AddObserver {
        return { oldObserver, update in
            if let oldObserver = oldObserver {
                NotificationCenter.default.removeObserver(oldObserver)
            }
            return NotificationCenter.default.addObserver(
                forName: RatesUpdateObserving.notificationName,
                object: nil,
                queue: .main
            ) { notification in
                guard let rate = notification.userInfo?[pair] as? ExchangeRate else { return }
                update(rate)
            }
        }
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
        updateTimer.observe {
            future().on(success: { rates in
                NotificationCenter.default.post(
                    name: RatesUpdateObserving.notificationName,
                    object: nil,
                    userInfo: .init(rates.map { ($0.pair, $0) }, uniquingKeysWith: { $1 })
                )
            })
        }
    }
}
