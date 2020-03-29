import SwiftUI


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


public struct CurrenciesList<SecondView: View>: View {

    let items: [CurrencyRow.Value]
    let bundle: Bundle
    let onSelect: ((Int) -> SecondView)?

    public init(items: [CurrencyRow.Value], bundle: Bundle, onSelect: ((Int) -> SecondView)?) {
        self.items = items
        self.bundle = bundle
        self.onSelect = onSelect
    }

    public var body: some View {
        List(items.indices) { index in
            ZStack(alignment: .leading) {
                CurrencyRow(self.items[index], bundle: self.bundle)

                self.onSelect.map { onSelect in
                    NavigationLink(destination: onSelect(index)) {
                        SwiftUI.EmptyView()
                    }
                }
            }
        }
        .listSeparatorStyle(.none)
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
}

extension CurrenciesList where SecondView == Never {
    public init(items: [CurrencyRow.Value], bundle: Bundle) {
        self.items = items
        self.bundle = bundle
        self.onSelect = nil
    }
}
