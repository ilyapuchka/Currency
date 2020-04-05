import Foundation

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
public typealias Reducer<State, Event> = (inout State, Event) -> [AnyPublisher<Event, Never>]

@available(iOS 13.0, *)
public class StateMachine<State, Event> {
    deinit {
        Swift.print("deinit")
    }
    
    let reduce: Reducer<State, Event>
    @Published private var state: State
    var bag = Set<AnyCancellable>()

    public static func make<Root: AnyObject>(
        assignTo stateKeyPath: ReferenceWritableKeyPath<Root, State>,
        on stateOwner: Root,
        input: ( @escaping (Event) -> Void ) -> AnyCancellable,
        reduce: @escaping Reducer<State, Event>
    ) -> AnyCancellable {
        let machine = StateMachine(initial: stateOwner[keyPath: stateKeyPath], reduce: reduce)
        machine.$state.sink { [weak stateOwner] (state) in
            stateOwner?[keyPath: stateKeyPath] = state
        }.store(in: &machine.bag)
        return input { (event) in
            machine.performEffects(effects: reduce(&machine.state, event))
        }
    }

    init(
        initial: State,
        reduce: @escaping Reducer<State, Event>
    ) {
        self.state = initial
        self.reduce = reduce
    }

    private func performEffects(effects: [AnyPublisher<Event, Never>]) {
        effects.forEach { [unowned self] effect in
            effect.receive(on: DispatchQueue.main).sink { (event) in
                let effects = self.reduce(&self.state, event)
                self.performEffects(effects: effects)
            }.store(in: &bag)
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
