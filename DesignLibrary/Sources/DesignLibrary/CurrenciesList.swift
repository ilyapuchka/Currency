import SwiftUI


public struct CurrencyRow: View {
    public struct Value: Identifiable {
        public var id: String { code }

        public let code: String
        let name: LocalizedStringKey
        let isEnabled: Bool

        public init(
            code: String,
            name: LocalizedStringKey,
            isEnabled: Bool
        ) {
            self.code = code
            self.name = name
            self.isEnabled = isEnabled
        }
    }

    let value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Color(.lightGray)
                Image(value.code).renderingMode(.original)
            }
            .clipShape(Circle())
            .frame(width: 24, height: 24)
            .opacity(value.isEnabled ? 1 : 0.5)

            Text(value.code)
                .font(.body)
                .foregroundColor(Color(DesignLibrary.Colors.secondaryText))

            Text(value.name)
                .font(.body)
                .foregroundColor(value.isEnabled
                    ? Color(DesignLibrary.Colors.regularText)
                    : Color(DesignLibrary.Colors.secondaryText)
                )
                .lineLimit(nil)

        }
        .frame(minHeight: 56)
        .padding(.trailing, 8)
    }
}


public struct CurrenciesList: View {
    let error: Error?
    let onRetry: (() -> Void)?
    let items: [CurrencyRow.Value]
    let onSelect: (CurrencyRow.Value) -> Void

    public init(
        items: [CurrencyRow.Value],
        error: Error?,
        onRetry: (() -> Void)?,
        onSelect: @escaping (CurrencyRow.Value) -> Void
    ) {
        self.error = error
        self.onRetry = onRetry
        self.items = items
        self.onSelect = onSelect
    }

    @ViewBuilder
    public var body: some View {
        if error != nil { self.retry }
        else { self.list }
    }

    var retry: some View {
        EmptyState(
            actionImage: nil,
            actionTitle: "retry",
            description: "failed_to_get_currency_list",
            action: { self.onRetry?() }
        )
    }

    var list: some View {
        List(self.items, id: \.id) { item in
            Button(action: { item.isEnabled ? self.onSelect(item) : () }) {
                CurrencyRow(item)
            }
        }
    }
}
