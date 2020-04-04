import SwiftUI

public struct EmptyState: View {
    @Environment(\.designLibrary) var designLibrary

    let actionImage: KeyPath<DesignLibrary, UIImage>?
    let actionTitle: LocalizedStringKey
    let description: LocalizedStringKey
    let action: () -> Void

    public init(
        actionImage: KeyPath<DesignLibrary, UIImage>?,
        actionTitle: LocalizedStringKey,
        description: LocalizedStringKey,
        action: @escaping () -> Void
    ) {
        self.actionImage = actionImage
        self.actionTitle = actionTitle
        self.description = description
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 8) {
                Button(action: action) {
                    VStack(spacing: 8) {
                        actionImage.map { designLibrary[keyPath: $0] }.map(Image.init)?
                            .resizable()
                            .frame(width: 60, height: 60)
                        Text(actionTitle)
                    }
                }
                .font(.headline)
                .foregroundColor(Color(designLibrary.colors.cta))
            }
            Text(description)
                .font(.subheadline)
                .foregroundColor(Color(designLibrary.colors.secondaryText))
        }
    }
}
