import SwiftUI

public struct DesignLibrary {
    public enum Colors: String {
        case regularText
        case secondaryText
        case cta
    }

    public enum Assets: String {
        case plus
    }
}

struct CTAStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(Color(DesignLibrary.Colors.cta))
    }
}

extension Button {
    func buttonStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}

extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}

extension Color {
    public init(_ named: DesignLibrary.Colors) {
        self.init(named.rawValue)
    }
}

extension Image {
    public init(_ named: DesignLibrary.Assets) {
        self.init(named.rawValue)
    }
}
