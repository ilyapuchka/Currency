#if canImport(SwiftUI) && DEBUG
import SwiftUI
import DesignLibrary

@available(iOS 13.0, *)
class CurrencyPairRowView_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
        let designLibrary = DesignLibrary(bundle: Bundle(for: Self.self))
        let view = CurrencyPairRowView(designLibrary: designLibrary)
        view.configure(
            from: (amount: "1 GBP", name: "Pounds"),
            to: (amount: "1.23456 EUR", name: "Euro")
        )
        return view
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
