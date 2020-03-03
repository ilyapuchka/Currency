import UIKit

public protocol Component {
    associatedtype View: UIView

    func makeView() -> View
    func render(in view: View)
}

public extension Component {
    func asAnyComponent() -> AnyComponent {
        AnyComponent(self)
    }
    func makeView() -> View {
        View()
    }
}

public struct AnyComponent: Component, SelectableComponent, DeletableComponent {
    private let wrapped: AnyComponentBoxBase
    public let componentType: Any.Type
    public let viewType: Any.Type

    private let selectable: SelectableComponent?
    private let deletable: DeletableComponent?

    init<Base: Component>(_ wrapped: Base) {
        self.wrapped = AnyComponentBox(wrapped)
        self.componentType = Base.self
        self.viewType = Base.View.self
        self.selectable = wrapped as? SelectableComponent
        self.deletable = wrapped as? DeletableComponent
    }

    public func makeView() -> UIView {
        wrapped.makeView()
    }

    public func render(in view: UIView) {
        wrapped.render(in: view)
    }

    public func didSelect() {
        selectable?.didSelect()
    }

    public func shouldSelect() -> Bool {
        selectable?.shouldSelect() ?? false
    }

    public func shouldPersistSelectionBetweenStateUpdates() -> Bool {
        selectable?.shouldPersistSelectionBetweenStateUpdates() ?? false
    }

    public func didDelete() {
        deletable?.didDelete()
    }
}

private protocol AnyComponentBoxBase {
    func makeView() -> UIView
    func render(in view: UIView)
}

private struct AnyComponentBox<Wrapped: Component>: AnyComponentBoxBase {
    let wrapped: Wrapped

    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    func makeView() -> UIView {
        wrapped.makeView()
    }

    func render(in view: UIView) {
        wrapped.render(in: view as! Wrapped.View)
    }
}

public protocol SelectableComponent {
    func didSelect()
    func shouldSelect() -> Bool
    func shouldPersistSelectionBetweenStateUpdates() -> Bool
}

extension SelectableComponent {
    public func shouldPersistSelectionBetweenStateUpdates() -> Bool {
        return true
    }
}

public protocol DeletableComponent {
    func didDelete()
}
