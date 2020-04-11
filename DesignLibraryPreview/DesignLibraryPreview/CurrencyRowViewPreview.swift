#if DEBUG
import SwiftUI
import DesignLibrary

class CurrenciesList_Preview: PreviewProvider {
    static var previews: some View {
        CurrenciesList(
            items: [
                .init(
                    code: "EUR",
                    name: "Some country with very very very very very long name Some country with very very very very very long name",
                    isEnabled: false
                ),
                .init(
                    code: "USD",
                    name: "Some country with very very very very very long name Some country with very very very very very long name",
                    isEnabled: true
                ),
            ],
            onSelect: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif
