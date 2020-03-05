import UIKit
import DesignLibrary

public protocol ViewModelProtocol {
    associatedtype State
    associatedtype UserAction

    typealias Reducer<Event> = (inout State, Event) -> [Future<Event, Never>]

    func sendAction(_ action: UserAction)
    func observeState(_ observer: @escaping (State) -> Void)
}

open class ViewModelViewController<ViewModel: ViewModelProtocol>: UIViewController {
    let viewModel: ViewModel
    private var components: [AnyComponent]

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.components = []
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func render(state: ViewModel.State, sendAction: @escaping (ViewModel.UserAction) -> Void) -> [AnyComponent] {
        return []
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        viewModel.observeState { [unowned self] state in
            let components = self.render(state: state, sendAction: self.viewModel.sendAction)
            components.forEach {
                $0.render(in: $0.makeView())
            }
            self.components = components
        }
    }
}
