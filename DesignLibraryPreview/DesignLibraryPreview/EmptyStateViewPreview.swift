#if DEBUG
import SwiftUI
import DesignLibrary

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
