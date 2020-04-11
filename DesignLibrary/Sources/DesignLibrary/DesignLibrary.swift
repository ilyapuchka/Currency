import SwiftUI

public class DesignLibraryKey: EnvironmentKey {
    public static var defaultValue: DesignLibrary = DesignLibrary(bundle: Bundle(for: DesignLibraryKey.self))
}

extension EnvironmentValues {
    public var designLibrary: DesignLibrary {
        get { self[DesignLibraryKey.self] }
        set { self[DesignLibraryKey.self] = newValue }
    }
}

public struct DesignLibrary {
    public let bundle: Bundle
    public let colors: Colors
    public let assets: Assets

    public init(bundle: Bundle!) {
        self.bundle = bundle
        self.colors = Colors(bundle: bundle)
        self.assets = Assets(bundle: bundle)
    }
}

extension DesignLibrary {
    public struct Colors {
        let bundle: Bundle

        public var regularText: UIColor {
            UIColor(named: #function, in: bundle, compatibleWith: nil)!
        }
        public var secondaryText: UIColor {
            UIColor(named: #function, in: bundle, compatibleWith: nil)!
        }
        public var cta: UIColor {
            UIColor(named: #function, in: bundle, compatibleWith: nil)!
        }
    }

    public struct Assets {
        let bundle: Bundle

        public var plus: UIImage {
            UIImage(named: "plus", in: bundle, compatibleWith: nil)!
        }
    }
}
