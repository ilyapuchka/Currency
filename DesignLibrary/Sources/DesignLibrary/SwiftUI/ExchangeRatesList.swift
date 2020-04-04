import SwiftUI

public struct ExchangeRatesList: View {
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

    @State private var items: [Item]

    public init(items: [Item]) {
        self._items = State(initialValue: items)
    }

    public var body: some View {
        VStack {
            List {
                AddCurrencyPairRow()
                ForEach(items) { (item) in
                    ExchangeRateRow(
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
