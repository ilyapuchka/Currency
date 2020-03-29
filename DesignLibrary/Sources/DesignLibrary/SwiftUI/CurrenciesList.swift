import SwiftUI

@available(iOS 13.0, *)
public struct CurrencyRow: View {
    public struct Value: Identifiable {
        public var id: String { code }

        let code: String
        let name: String
        let isEnabled: Bool

        public init(
            code: String,
            name: String,
            isEnabled: Bool
        ) {
            self.code = code
            self.name = name
            self.isEnabled = isEnabled
        }
    }

    let value: Value

    let bundle: Bundle
    var designLibrary: DesignLibrary {
        DesignLibrary(bundle: bundle)
    }

    public init(
        _ value: Value,
        bundle: Bundle
    ) {
        self.value = value
        self.bundle = bundle
    }

    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Color(.lightGray)
                Image(value.code, bundle: bundle)
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

@available(iOS 13.0, *)
public struct CurrenciesList: View {

    let items: [CurrencyRow.Value]
    let bundle: Bundle

    public init(items: [CurrencyRow.Value], bundle: Bundle) {
        self.items = items
        self.bundle = bundle
    }

    public var body: some View {
        List(items) { item in
            CurrencyRow(item, bundle: self.bundle)
        }
        .listSeparatorStyle(.none)
    }
}
