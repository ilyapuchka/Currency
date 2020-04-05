import Foundation

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
public typealias Reducer<State, Event> = (inout State, Event) -> [AnyPublisher<Event, Never>]

@available(iOS 13.0, *)
public class StateMachine<State, Event>: ObservableObject {
    let reduce: Reducer<State, Event>
    @Published public private(set) var state: State

    public init(
        initial: State,
        reduce: @escaping Reducer<State, Event>
    ) {
        self.state = initial
        self.reduce = reduce
    }
}

@available(iOS 13.0, *)
extension StateMachine {
    public func sink(event: Event) {
        performEffects(effects: reduce(&state, event))
    }

    private func performEffects(effects: [AnyPublisher<Event, Never>]) {
        effects.forEach { [unowned self] effect in
            _ = effect.receive(on: DispatchQueue.main).sink { (event) in
                let effects = self.reduce(&self.state, event)
                self.performEffects(effects: effects)
            }
        }
    }
}
#else
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

    public func observeState(sendInitial: Bool = false, _ observer: @escaping (State) -> Void) {
        observers.append(observer)
        if sendInitial {
            observer(state)
        }
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
#endif
