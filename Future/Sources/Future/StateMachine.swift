import Foundation

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
@dynamicMemberLookup
public protocol StateMachine: ObservableObject {
    associatedtype State
    associatedtype UserAction
    associatedtype Event

    typealias Reducer = (inout State, Event) -> [AnyPublisher<Event, Never>]

    var reduce: Reducer { get }
    var state: State { get set }

    func sendAction(_ action: UserAction)
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

    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
        set {}
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
