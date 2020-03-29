import SwiftUI

@available(iOS 13.0.0, *)
struct AddCurrencyPairRow: View {
    let bundle: Bundle

    var body: some View {
        let designLibrary = DesignLibrary(bundle: bundle)
        return HStack(spacing: 16) {
            Image(uiImage: designLibrary.assets.plus)
                .resizable()
                .frame(width: 40, height: 40)
            Text("add_currency_pair_button_title", bundle: bundle)
                .font(.headline)
                .foregroundColor(Color(designLibrary.colors.cta))
        }.frame(height: 56)
    }
}
