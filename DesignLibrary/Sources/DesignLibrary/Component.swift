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

public struct AnyComponent: Component {
    let wrapped: Any
    let wrappedBox: AnyComponentBoxBase
    let componentType: Any.Type
    let viewType: Any.Type

    init<Base: Component>(_ wrapped: Base) {
        self.wrapped = wrapped
        self.wrappedBox = AnyComponentBox(wrapped)
        self.componentType = Base.self
        self.viewType = Base.View.self
    }

    public func makeView() -> UIView {
        wrappedBox.makeView()
    }

    public func render(in view: UIView) {
        wrappedBox.render(in: view)
    }

    public static var empty: AnyComponent {
        return ViewComponent().asAnyComponent()
    }
}

extension AnyComponent: SelectableComponent {
    var selectable: SelectableComponent? {
        return (wrapped as? ModifiedComponent)?.component
            ?? wrapped as? SelectableComponent
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
}

extension AnyComponent: DeletableComponent {
    var deletable: DeletableComponent? {
        return (wrapped as? ModifiedComponent)?.component
            ?? wrapped as? DeletableComponent
    }

    public func didDelete() {
        deletable?.didDelete()
    }
}

struct ViewComponent: Component {
    func render(in view: UIView) {}
}

protocol AnyComponentBoxBase {
    func makeView() -> UIView
    func render(in view: UIView)

    #if DEBUG
    func unwrap<T: Component>() -> T?
    #endif
}

struct AnyComponentBox<Wrapped: Component>: AnyComponentBoxBase {
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

#if DEBUG
extension AnyComponentBox {
    func unwrap<T: Component>() -> T? {
        if let wrapped = wrapped as? T {
            return wrapped
        } else if let modified = wrapped as? ModifiedComponent {
            return modified.unwrap()
        } else if let boxed = wrapped as? AnyComponentBox {
            return boxed.unwrap()
        } else {
            return nil
        }
    }
}
#endif

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
