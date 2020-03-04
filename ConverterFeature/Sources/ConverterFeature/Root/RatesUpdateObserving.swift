import Foundation
import Domain

struct RatesUpdateObserving {
    static let notificationName = NSNotification.Name("ratesUpdated")

    typealias Observer = (CurrencyPair) -> (@escaping (ExchangeRate) -> Void) -> Void

    static func observeUpdates(_ pair: CurrencyPair) -> (@escaping (ExchangeRate) -> Void) -> Void {
        return { update in
            NotificationCenter.default.addObserver(
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
