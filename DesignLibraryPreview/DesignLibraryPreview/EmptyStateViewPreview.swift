#if canImport(SwiftUI) && DEBUG
import SwiftUI
import DesignLibrary


class EmptyStateView_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
        let bundle = Bundle(for: Self.self)
        let designLibrary = DesignLibrary(bundle: bundle)

        let host = UIView()
        let component = HostViewComponent.init(host: host, alignment: .center) {
            EmptyStateViewComponent(
                bundle: bundle,
                designLibrary: designLibrary,
                actionImage: \DesignLibrary.assets.plus,
                actionTitle: "Action",
                description: "Description",
                action: {}
            )
        }
        component.render(in: component.makeView())
        return host
    }
    .previewLayout(.sizeThatFits)
  }
}

class EmptyState_Preview: PreviewProvider {
  static var previews: some View {
    return EmptyState(
        actionImage: \.assets.plus,
        actionTitle: "Action",
        description: "Description",
        action: {}
    )
        .previewLayout(.sizeThatFits)
  }
}
#endif
