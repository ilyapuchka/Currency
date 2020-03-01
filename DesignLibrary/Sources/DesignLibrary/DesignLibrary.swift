import UIKit

public struct DesignLibrary {
    public let colors: Colors

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

    public init(bundle: Bundle) {
        self.colors = Colors(bundle: bundle)
    }
}
