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
                let vc = TableViewController(coder: coder)!
                vc.update(sections: [
                    [
                        AddCurrencyPairButtonComponent(bundle: bundle, designLibrary: designLibrary).asAnyComponent(),
                        CurrencyRowViewComponent(
                            designLibrary: designLibrary,
                            image: UIImage(named: "EUR", in: bundle, compatibleWith: nil)!,
                            code: "EUR",
                            name: "Euro").asAnyComponent()
                    ]
                ])
                return vc
        }!
      }.previewLayout(.sizeThatFits)
  }
}
#endif
