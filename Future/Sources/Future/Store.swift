import Foundation
import Combine

public typealias Reducer<State, Event> = (inout State, Event) -> [AnyPublisher<Event, Never>]

public func store<Root: AnyObject, State, Event>(
    assignTo stateKeyPath: ReferenceWritableKeyPath<Root, State>,
    on stateOwner: Root,
    input: ( @escaping (Event) -> Void ) -> AnyCancellable,
    reduce: @escaping Reducer<State, Event>,
    bag: inout Set<AnyCancellable>
) {
    let store = Store(initial: stateOwner[keyPath: stateKeyPath], reduce: reduce)
    store.$state
        .assign(to: stateKeyPath, on: stateOwner)
        .store(in: &store.bag)

    input { (event) in
        store.performEffects(effects: reduce(&store.state, event))
    }.store(in: &bag)
}

public class Store<State, Event> {
    let reduce: Reducer<State, Event>
    @Published fileprivate var state: State
    var bag = Set<AnyCancellable>()

    init(
        initial: State,
        reduce: @escaping Reducer<State, Event>
    ) {
        self.state = initial
        self.reduce = reduce
    }

    fileprivate func performEffects(effects: [AnyPublisher<Event, Never>]) {
        effects.forEach { [unowned self] effect in
            effect.receive(on: DispatchQueue.main).sink { (event) in
                let effects = self.reduce(&self.state, event)
                self.performEffects(effects: effects)
            }.store(in: &bag)
        }
    }
}

@dynamicMemberLookup
public protocol ObservableViewState: ObservableObject {
    associatedtype State
    associatedtype Action

    var state: State { get }
    func sendAction(_ action: Action)
}

extension ObservableViewState {
    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        state[keyPath: keyPath]
    }
}
