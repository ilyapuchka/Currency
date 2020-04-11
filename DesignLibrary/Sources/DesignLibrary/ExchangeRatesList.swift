import SwiftUI

public struct ExchangeRatesList: View {
    public struct Item: Identifiable {
        public let id: Int
        let from: ExchangeRateRow.Labels
        let to: ExchangeRateRow.Labels

        public init(
            id: Int,
            from: ExchangeRateRow.Labels,
            to: ExchangeRateRow.Labels
        ) {
            self.id = id
            self.from = from
            self.to = to
        }
    }

    let items: [Item]
    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    public init(
        items: [Item],
        onAdd: @escaping () -> Void,
        onDelete: @escaping (IndexSet) -> Void
    ) {
        self.items = items
        self.onAdd = onAdd
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack {
            List {
                Button(action: self.onAdd) {
                    AddCurrencyPairRow()
                }
                ForEach(items) { (item) in
                    ExchangeRateRow(from: item.from, to: item.to)
                }
                .onDelete(perform: onDelete)
            }
        }
    }
}
