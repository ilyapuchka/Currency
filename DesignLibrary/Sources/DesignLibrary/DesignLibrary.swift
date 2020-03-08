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

    public let assets: Assets
    
    public struct Assets {
        let bundle: Bundle

        public var plus: UIImage {
            UIImage(named: "plus", in: bundle, compatibleWith: nil)!
        }
    }

    public init(bundle: Bundle) {
        self.colors = Colors(bundle: bundle)
        self.assets = Assets(bundle: bundle)
    }
}
