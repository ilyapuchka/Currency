import Foundation
import Combine

public typealias Reducer<State, Event> = (inout State, Event) -> [AnyPublisher<Event, Never>]

public class StateMachine<State, Event> {
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
