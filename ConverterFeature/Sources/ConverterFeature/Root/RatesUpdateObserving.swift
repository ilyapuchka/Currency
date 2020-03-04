import Foundation
import Domain

struct RatesUpdateObserving {
    static let notificationName = NSNotification.Name("ratesUpdated")

    typealias AddObserver = (_ oldObserver: Any?, _ update: @escaping (ExchangeRate) -> Void) -> Any

    static func observeUpdates(_ pair: CurrencyPair) -> AddObserver {
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

    static func post(rates: [ExchangeRate]) -> Void {
        NotificationCenter.default.post(
            name: RatesUpdateObserving.notificationName,
            object: nil,
            userInfo: .init(rates.map { ($0.pair, $0) }, uniquingKeysWith: { $1 })
        )
    }

    private let updateTimer = Timer(repeatInterval: 1)

    func pause() {
        updateTimer.pause()
    }

    func start() {
        updateTimer.start()
    }

    func observe(_ handler: @escaping () -> Void) {
        updateTimer.observe(handler)
    }
}
