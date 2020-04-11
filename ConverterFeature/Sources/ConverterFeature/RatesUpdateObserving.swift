import Foundation
import Domain
import Future

public protocol RatesUpdateObserving {
    func start()
    func pause()

    /// Sets a closure to run to update exchange rates. The closure should create a future value of updated exchange rates
    func update<S: Subscriber>(
        subscriber: S,
        _ future: @escaping () -> AnyPublisher<[ExchangeRate], Error>
    ) where S.Input == [ExchangeRate], S.Failure == Never

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
    var bag = Set<AnyCancellable>()

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
}
