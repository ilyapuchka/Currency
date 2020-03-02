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

public struct AnyComponent: Component, SelectableComponent {
    private let wrapped: AnyComponentBoxBase
    public let componentType: Any.Type
    public let viewType: Any.Type

    private let selectable: SelectableComponent?

    init<Base: Component>(_ wrapped: Base) {
        self.wrapped = AnyComponentBox(wrapped)
        self.componentType = Base.self
        self.viewType = Base.View.self
        self.selectable = wrapped as? SelectableComponent
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
}
