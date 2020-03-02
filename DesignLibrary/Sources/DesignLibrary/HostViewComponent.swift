import UIKit

public struct HostViewComponent: Component {
    public enum Alignment {
        case fill
        case center
    }

    let host: UIView
    var contentView: UIView?
    let alignment: Alignment
    let component: AnyComponent

    public init(
        host: UIView,
        alignment: Alignment,
        component: () -> AnyComponent
    ) {
        self.host = host
        self.contentView = nil
        self.alignment = alignment
        self.component = component()
    }

    public func makeView() -> UIView {
        if let subview = host.subviews.first, component.viewType == type(of: subview) {
            return subview
        }
        host.subviews.first?.removeFromSuperview()
        let contentView = component.makeView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }

    public func render(in view: UIView) {
        if let subview = host.subviews.first, component.viewType == type(of: subview) {
            component.render(in: view)
            return
        }

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
