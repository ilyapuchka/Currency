import UIKit
import DesignLibrary
import Future

#if !canImport(Combine)
public protocol ViewModelProtocol {
    associatedtype State
    associatedtype UserAction
    associatedtype Event

    typealias Reducer = (inout State, Event) -> [Future<Event, Never>]

    var state: StateMachine<State, Event> { get }

    func sendAction(_ action: UserAction)
}

extension ViewModelProtocol {
    func observeState(sendInitial: Bool, _ observer: @escaping (State) -> Void) {
        state.observeState(sendInitial: sendInitial, observer)
    }
}
#endif

#if !canImport(SwiftUI)
open class ViewModelViewController<ViewModel: ViewModelProtocol>: UIViewController {
    let viewModel: ViewModel
    private var component: AnyComponent

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.component = .empty
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func render(state: ViewModel.State, sendAction: @escaping (ViewModel.UserAction) -> Void) -> AnyComponent {
        return .empty
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        viewModel.observeState(sendInitial: true) { [unowned self] state in
            let component = self.render(state: state, sendAction: self.viewModel.sendAction)
            component.render(in: component.makeView())
            self.component = component
        }
    }
}
#endif
