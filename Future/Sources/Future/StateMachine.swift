public class StateMachine<State, Event> {
    public private(set) var state: State {
        didSet {
            observers.forEach { $0(state) }
        }
    }
    private var observers: [(State) -> Void] = []
    private let reduce: (inout State, Event) -> [Future<Event, Never>]

    public init(
        initial: State,
        reduce: @escaping (inout State, Event) -> [Future<Event, Never>]
    ) {
        self.state = initial
        self.reduce = reduce
    }

    public func sink(event: Event) {
        performEffects(effects: reduce(&state, event))
    }

    public func observeState(_ observer: @escaping (State) -> Void) {
        observers.append(observer)
    }

    private func performEffects(effects: [Future<Event, Never>]) {
        effects.forEach { [unowned self] future in
            future.observe(on: .mainQueue()).on(success: { event in
                let effects = self.reduce(&self.state, event)
                self.performEffects(effects: effects)
            })
        }
    }
}
