import SwiftUI

struct AddCurrencyPairRow: View {
    @Environment(\.designLibrary) var designLibrary

    var body: some View {
        return HStack(spacing: 16) {
            Image(uiImage: designLibrary.assets.plus)
                .resizable()
                .frame(width: 40, height: 40)
            Text("add_currency_pair_button_title", bundle: designLibrary.bundle)
                .font(.headline)
                .foregroundColor(Color(designLibrary.colors.cta))
        }.frame(height: 56)
    }
}
