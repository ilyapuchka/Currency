import Foundation

final class Timer {
    private let source: DispatchSourceTimer
    private(set) var isRunning: Bool = false

    init(repeatInterval: Double) {
        source = DispatchSource.makeTimerSource(queue: .main)
        let deadline: DispatchTime = .now() + repeatInterval
        source.schedule(deadline: deadline, repeating: repeatInterval)
    }

    func observe(_ handler: @escaping () -> Void) {
        source.setEventHandler(handler: handler)
    }

    func start() {
        guard !self.isRunning else { return }
        self.source.resume()
        self.isRunning = true
    }

    func pause() {
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
