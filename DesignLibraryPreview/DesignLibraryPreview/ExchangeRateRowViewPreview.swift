#if DEBUG
import SwiftUI
import DesignLibrary

class ExchangeRateRowView_Preview: PreviewProvider {
    static var previews: some View {
        ExchangeRatesList(items: [
            ExchangeRatesList.Item(
                id: "GBPUSD",
                from: (amount: "1 GBP", description: "Pounds"),
                to: (amount: "1.5 USD", description: "US Dollars")
            ),
            ExchangeRatesList.Item(
                id: "USDGBP",
                from: (amount: "1.5 USD", description: "US Dollars"),
                to: (amount: "1 GBP", description: "Pounds")
            )
        ])
            .previewLayout(.sizeThatFits)
    }
}
#endif
