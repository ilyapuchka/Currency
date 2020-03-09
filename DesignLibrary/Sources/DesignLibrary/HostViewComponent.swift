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
    let accessibilityIdentifier: String?

    public init(
        host: UIView,
        alignment: Alignment,
        accessibilityIdentifier: String? = nil,
        component: () -> T
    ) {
        self.host = host
        self.contentView = nil
        self.alignment = alignment
        self.component = component()
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public func makeView() -> T.View {
        if let subview = host.subviews.first as? T.View {
            return subview
        }
        let contentView = component.makeView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.accessibilityIdentifier = accessibilityIdentifier
        return contentView
    }

    public func render(in view: T.View) {
        if let subview = host.subviews.first as? T.View {
            component.render(in: subview)
            return
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
