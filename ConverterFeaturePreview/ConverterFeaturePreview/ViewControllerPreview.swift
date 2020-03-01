#if canImport(SwiftUI) && DEBUG
import SwiftUI
import ConverterFeature
import DesignLibrary

@available(iOS 13.0, *)
class ViewController_Preview: PreviewProvider {
  static var previews: some View {
      UIViewControllerPreview {
        UIStoryboard(name: "Preview", bundle: Bundle.init(for: Self.self))
            .instantiateInitialViewController { coder in
                let bundle = Bundle(for: Self.self)
                let designLibrary = DesignLibrary(bundle: bundle)
                return ViewController(coder: coder, bundle: bundle, designLibrary: designLibrary)
        }!
      }.previewLayout(.sizeThatFits)
  }
}
#endif
