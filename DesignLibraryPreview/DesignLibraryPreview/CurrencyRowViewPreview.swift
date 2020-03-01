#if canImport(SwiftUI) && DEBUG
import SwiftUI
import DesignLibrary

@available(iOS 13.0, *)
class CurrencyRowView_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
        let bundle = Bundle(for: Self.self)
        let designLibrary = DesignLibrary(bundle: bundle)
        let view = CurrencyRowView(designLibrary: designLibrary)
        let image = UIImage(named: "EUR", in: bundle, with: nil)!
        view.configure(image: image, code: "ABC", name: "Some country with very very very very very long name Some country with very very very very very long name")
        return view
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
