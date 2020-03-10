import UIKit

public protocol ComponentModifier {
    associatedtype Modified: Component

    func modify(view: Modified.View)
}

public struct AnyComponentModifier: ComponentModifier {
    public typealias Modified = AnyComponent

    let wrapped: AnyComponentModifierBoxBase
    let componentType: Any.Type
    let viewType: Any.Type

    init<Base: ComponentModifier>(_ wrapped: Base) {
        self.wrapped = AnyComponentModifierBox(wrapped)
        self.componentType = Base.self
        self.viewType = Base.Modified.View.self
    }

    public func modify(view: UIView) {
        wrapped.modify(view: view)
    }
}

public extension ComponentModifier {
    func asAnyComponentModifier() -> AnyComponentModifier {
        AnyComponentModifier(self)
    }
}

protocol AnyComponentModifierBoxBase {
    func modify(view: UIView)
}

struct AnyComponentModifierBox<Wrapped: ComponentModifier>: AnyComponentModifierBoxBase {
    let wrapped: Wrapped

    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    func modify(view: UIView) {
        wrapped.modify(view: view as! Wrapped.Modified.View)
    }
}

public struct ModifiedComponent: Component {
    var component: AnyComponent
    var modifier: AnyComponentModifier

    public func makeView() -> UIView {
        component.makeView()
    }

    public func render(in view: UIView) {
        component.render(in: view)
        modifier.modify(view: view)
    }
}

#if DEBUG
extension ModifiedComponent {
    func unwrap<T: Component>() -> T? {
        component.wrappedBox.unwrap()
    }
}
#endif

public struct AccessibilityModifier<Modified: Component>: ComponentModifier {
    public let accessibilityLabel: String?
    public let accessibilityIdentifier: String

    public init(accessibilityLabel: String?, accessibilityIdentifier: String) {
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public func modify(view: Modified.View) {
        view.accessibilityIdentifier = accessibilityIdentifier
        view.accessibilityLabel = accessibilityLabel
    }
}

public extension Component {
    func accessibility(label: String? = nil, identifier: String) -> ModifiedComponent {
        ModifiedComponent(
            component: asAnyComponent(),
            modifier: AccessibilityModifier<Self>(
                accessibilityLabel: label,
                accessibilityIdentifier: identifier
            ).asAnyComponentModifier()
        )
    }
}
