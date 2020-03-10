import UIKit

public struct HostViewComponent<T: Component>: Component {
    public enum Alignment {
        case fill
        case center
    }

    let host: UIView
    var contentView: T.View?
    let alignment: Alignment
    let component: T

    public init(
        host: UIView,
        alignment: Alignment,
        component: () -> T
    ) {
        self.host = host
        self.contentView = nil
        self.alignment = alignment
        self.component = component()
    }

    public func makeView() -> T.View {
        if let reused = host.reuseComponentView(component: component) {
            return reused
        }
        let contentView = component.makeView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }

    public func render(in view: T.View) {
        if let reused = host.reuseComponentView(component: component) {
            return component.render(in: reused)
        }

        host.subviews.first?.removeFromSuperview()
        host.addSubview(view)

        switch alignment {
        case .fill:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.trailingAnchor),
                view.topAnchor.constraint(equalTo: host.safeAreaLayoutGuide.topAnchor),
                view.bottomAnchor.constraint(equalTo: host.safeAreaLayoutGuide.bottomAnchor)
            ])
        case .center:
            NSLayoutConstraint.activate([
                view.centerYAnchor.constraint(equalTo: host.centerYAnchor),
                view.leadingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.trailingAnchor)
            ])
        }
        component.render(in: view)
    }
}

extension UIView {
    func reuseComponentView<T: Component>(component: T) -> T.View? {
        guard let subview = self.subviews.first else { return nil }

        if let modified = component as? ModifiedComponent {
            if type(of: subview) == modified.component.viewType {
                return subview as? T.View
            }
        } else if type(of: subview) == T.View.self {
            return subview as? T.View
        }

        return nil
    }

    func reuseComponentView(component: AnyComponent) -> UIView? {
        guard let subview = self.subviews.first else { return nil }

        if let modified = component.wrapped as? ModifiedComponent {
            if type(of: subview) == modified.component.viewType {
                return subview
            }
        } else if type(of: subview) == component.viewType {
            return subview
        }

        return nil
    }
}
