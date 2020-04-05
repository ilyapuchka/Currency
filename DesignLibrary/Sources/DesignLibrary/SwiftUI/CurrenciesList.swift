import SwiftUI


public struct CurrencyRow: View {
    @Environment(\.designLibrary) var designLibrary

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
                Image(value.code, bundle: designLibrary.bundle).renderingMode(.original)
            }
            .clipShape(Circle())
            .frame(width: 24, height: 24)
            .opacity(value.isEnabled ? 1 : 0.5)

            Text(value.code)
                .font(.body)
                .foregroundColor(Color(designLibrary.colors.secondaryText))

            Text(value.name)
                .font(.body)
                .foregroundColor(value.isEnabled
                    ? Color(designLibrary.colors.regularText)
                    : Color(designLibrary.colors.secondaryText)
                )
                .lineLimit(nil)

        }
        .frame(minHeight: 56)
        .padding(.trailing, 8)
    }
}


public struct CurrenciesList: View {
    let items: [CurrencyRow.Value]
    let onSelect: (CurrencyRow.Value) -> Void

    public init(items: [CurrencyRow.Value], onSelect: @escaping (CurrencyRow.Value) -> Void) {
        self.items = items
        self.onSelect = onSelect
    }

    public var body: some View {
        List(items, id: \.id) { item in
            Button(action: { item.isEnabled ? self.onSelect(item) : () }) {
                CurrencyRow(item)
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle(Text(verbatim: ""))
    }
}
