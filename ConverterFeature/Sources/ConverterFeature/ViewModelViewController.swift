import UIKit
import DesignLibrary
import Future

public protocol ViewModelProtocol {
    associatedtype State
    associatedtype UserAction

    typealias Reducer<Event> = (inout State, Event) -> [Future<Event, Never>]

    func sendAction(_ action: UserAction)
    func observeState(sendInitial: Bool, _ observer: @escaping (State) -> Void)
}

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
