#if canImport(SwiftUI) && DEBUG
import SwiftUI
import DesignLibrary

@available(iOS 13.0, *)
class AddCurrencyPairButton_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
        let bundle = Bundle(for: Self.self)
        let designLibrary = DesignLibrary(bundle: bundle)
        let view = AddCurrencyPairButton(bundle: bundle, designLibrary: designLibrary)
        return view
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
