import SwiftUI

public struct EmptyState: View {
    let actionImage: DesignLibrary.Assets?
    let actionTitle: LocalizedStringKey
    let description: LocalizedStringKey
    let action: () -> Void

    public init(
        actionImage: DesignLibrary.Assets?,
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
                        actionImage.map(Image.init)?
                            .resizable()
                            .frame(width: 60, height: 60)
                        Text(actionTitle)
                    }
                }
                .buttonStyle(CTAStyle())
            }
            Text(description)
                .font(.subheadline)
                .foregroundColor(Color(DesignLibrary.Colors.secondaryText))
        }
    }
}
