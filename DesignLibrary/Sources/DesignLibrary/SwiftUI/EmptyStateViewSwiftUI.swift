import SwiftUI


public struct EmptyStateViewSwiftUI: View {
    let actionImage: KeyPath<DesignLibrary, UIImage>?
    let actionTitle: String
    let description: String
    let action: () -> Void

    let bundle: Bundle

    var designLibrary: DesignLibrary {
        DesignLibrary(bundle: bundle)
    }

    public init(
        actionImage: KeyPath<DesignLibrary, UIImage>?,
        actionTitle: String,
        description: String,
        action: @escaping () -> Void,
        bundle: Bundle
    ) {
        self.actionImage = actionImage
        self.actionTitle = actionTitle
        self.description = description
        self.action = action
        self.bundle = bundle
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
