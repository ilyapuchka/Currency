import Foundation

public final class Timer {
    private let source: DispatchSourceTimer
    private(set) var isRunning: Bool = false

    public init(repeatInterval: Double) {
        source = DispatchSource.makeTimerSource(queue: .main)
        let deadline: DispatchTime = .now() + repeatInterval
        source.schedule(deadline: deadline, repeating: repeatInterval)
    }

    public func observe(_ handler: @escaping () -> Void) {
        source.setEventHandler(handler: handler)
    }

    public func start() {
        guard !self.isRunning else { return }
        self.source.resume()
        self.isRunning = true
    }

    public func pause() {
        guard self.isRunning else { return }
        self.source.suspend()
        self.isRunning = false
    }

    deinit {
        source.cancel()
        // to avoid crash on deallocating canceled source
        source.resume()
    }
}
