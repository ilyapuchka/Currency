import SwiftUI

public struct ExchangeRateRow: View {
    @Environment(\.designLibrary) var designLibrary

    public typealias Labels = (amount: String, description: String)

    let from: Labels
    let to: Labels

    func label(amount: String, description: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(amount)
                .font(Font(UIFont.preferredFont(forTextStyle: .title2)))
                .foregroundColor(.init(designLibrary.colors.regularText))
            Text(description)
                .lineLimit(nil)
                .font(.subheadline)
                .foregroundColor(.init(designLibrary.colors.secondaryText))
        }
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            label(amount: from.amount, description: from.description, alignment: .leading)
            Spacer()
            label(amount: to.amount, description: to.description, alignment: .trailing)
        }
        .frame(minHeight: 56)
    }
}