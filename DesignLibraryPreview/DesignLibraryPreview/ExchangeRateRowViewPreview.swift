#if canImport(SwiftUI) && DEBUG
import SwiftUI
import DesignLibrary

@available(iOS 13.0, *)
class ExchangeRateRowView_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
        let bundle = Bundle(for: Self.self)
        let designLibrary = DesignLibrary(bundle: bundle)

        let component = TableViewComponent(sections: [[
            AddCurrencyPairViewComponent(
                bundle: bundle,
                designLibrary: designLibrary,
                action: {}
            ).asAnyComponent(),
            ExchangeRateViewComponent(
                designLibrary: designLibrary,
                from: (amount: "1 GBP", description: "Pounds"),
                to: (amount: "1.23456 EUR", description: "Euro"),
                onDelete: {},
                onRateUpdate: { _ in }
            ).asAnyComponent(),
            ExchangeRateViewComponent(
                designLibrary: designLibrary,
                from: (amount: "1 GBP", description: "Pounds"),
                to: (amount: "1.23456 EUR", description: "Euro"),
                onDelete: {},
                onRateUpdate: { _ in }
            ).asAnyComponent(),
            ExchangeRateViewComponent(
                designLibrary: designLibrary,
                from: (amount: "1 GBP", description: "Pounds"),
                to: (amount: "1.23456 EUR", description: "Euro"),
                onDelete: {},
                onRateUpdate: { _ in }
            ).asAnyComponent()
        ]])

        let view = component.makeView()
        component.render(in: view)
        return view
    }
    .previewLayout(.sizeThatFits)
  }
}

@available(iOS 13.0, *)
class ExchangeRateRowViewSwiftUI_Preview: PreviewProvider {
    static var previews: some View {
        ExchangeRatesList(bundle: Bundle(for: Self.self), items: [
            ExchangeRatesList.Item(
                id: "GBPUSD",
                from: (amount: "1 GBP", description: "Pounds"),
                to: (amount: "1.5 USD", description: "US Dollars")
            ),
            ExchangeRatesList.Item(
                id: "USDGBP",
                from: (amount: "1.5 USD", description: "US Dollars"),
                to: (amount: "1 GBP", description: "Pounds")
            )
        ])
            .previewLayout(.sizeThatFits)
    }
}
#endif
