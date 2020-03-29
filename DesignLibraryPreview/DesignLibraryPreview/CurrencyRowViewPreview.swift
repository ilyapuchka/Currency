#if canImport(SwiftUI) && DEBUG
import SwiftUI
import DesignLibrary


class CurrencyRowView_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
        let bundle = Bundle(for: Self.self)
        let designLibrary = DesignLibrary(bundle: bundle)

        let component = TableViewComponent(sections: [[
            CurrencyViewComponent(
                designLibrary: designLibrary,
                image: UIImage(named: "EUR", in: bundle, with: nil),
                code: "ABC",
                name: "Some country with very very very very very long name Some country with very very very very very long name",
                isEnabled: false,
                action: {}
            ).asAnyComponent(),
            CurrencyViewComponent(
                designLibrary: designLibrary,
                image: nil,
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


class CurrencyRow_Preview: PreviewProvider {
    static var previews: some View {
        CurrenciesList(
            items: [
                .init(
                    code: "EUR",
                    name: "Some country with very very very very very long name Some country with very very very very very long name",
                    isEnabled: false
                ),
                .init(
                    code: "USD",
                    name: "Some country with very very very very very long name Some country with very very very very very long name",
                    isEnabled: true
                ),
            ],
            bundle: Bundle(for: Self.self)
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif
