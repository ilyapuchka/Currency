import Foundation

final class Timer {
    private let source: DispatchSourceTimer
    private var isRunning: Bool = false

    init(repeatInterval: Double) {
        source = DispatchSource.makeTimerSource(queue: .main)
        let deadline: DispatchTime = DispatchTime.now() + 1
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
    }
}
