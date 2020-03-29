import SwiftUI


public struct ExchangeRatesList: View {
    let bundle: Bundle

    public struct Item: Identifiable {
        public let id: String
        let from: ExchangeRateRow.Labels
        let to: ExchangeRateRow.Labels

        public init(
            id: String,
            from: ExchangeRateRow.Labels,
            to: ExchangeRateRow.Labels
        ) {
            self.id = id
            self.from = from
            self.to = to
        }
    }

    @State var items: [Item]

    public init(bundle: Bundle, items: [Item]) {
        self.bundle = bundle
        self._items = State(initialValue: items)
    }

    public var body: some View {
        VStack {
            List {
                AddCurrencyPairRow(bundle: bundle)
                ForEach(items) { (item) in
                    ExchangeRateRow(
                        bundle: self.bundle,
                        from: item.from,
                        to: item.to,
                        onRateUpdate: { _ in }
                    )
                }
                .onDelete { removed in
                    self.items.remove(atOffsets: removed)
                }
            }
        }
    }
}
