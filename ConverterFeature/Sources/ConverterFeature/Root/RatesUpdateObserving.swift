import Foundation
import Domain

struct RatesUpdateObserving {
    static let notificationName = NSNotification.Name("ratesUpdated")

    typealias Observer = (CurrencyPair) -> (@escaping (ExchangeRate) -> Void) -> Void
    typealias Publisher = ([ExchangeRate]) -> Void

    private let updateTimer = Timer(repeatInterval: 1)

    let post: Publisher = { rates in
        NotificationCenter.default.post(
            name: RatesUpdateObserving.notificationName,
            object: nil,
            userInfo: Dictionary(rates.map { ($0.pair, $0) }, uniquingKeysWith: { $1 })
        )
    }

    let observer: Observer = { pair in
        return { update in
            NotificationCenter.default.addObserver(forName: RatesUpdateObserving.notificationName, object: nil, queue: .main) { notification in
                guard let rate = notification.userInfo?[pair] as? ExchangeRate else { return }
                update(rate)
            }
        }
    }

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
