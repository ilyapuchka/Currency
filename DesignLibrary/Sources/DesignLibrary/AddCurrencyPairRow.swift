import SwiftUI

struct AddCurrencyPairRow: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        return HStack(spacing: 16) {
            Image(.plus)
                .resizable()
                .frame(width: 40, height: 40)
            Text("add_currency_pair_button_title")
                .textStyle(CTAStyle())
        }.frame(height: 56)
    }
}
