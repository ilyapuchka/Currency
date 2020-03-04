#if canImport(SwiftUI) && DEBUG
import SwiftUI
import DesignLibrary

@available(iOS 13.0, *)
class CurrencyRowView_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
        let bundle = Bundle(for: Self.self)
        let designLibrary = DesignLibrary(bundle: bundle)

        let component = TableViewComponent(sections: [[
            CurrencyRowViewComponent(
                designLibrary: designLibrary,
                image: UIImage(named: "EUR", in: bundle, with: nil),
                code: "ABC",
                name: "Some country with very very very very very long name Some country with very very very very very long name",
                isEnabled: false,
                action: {}
            ).asAnyComponent(),
            CurrencyRowViewComponent(
                designLibrary: designLibrary,
                image: UIImage(named: "EUR", in: bundle, with: nil),
                code: "ABC",
                name: "Some country with very very very very very long name Some country with very very very very very long name",
                action: {}
            ).asAnyComponent()
            ]])

        let view = component.makeView()
        component.render(in: view)
        return view
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
