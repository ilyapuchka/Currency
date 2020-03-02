import UIKit
import ConverterFeature
import DesignLibrary
import DataAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let bundle = Bundle(for: Self.self)
        let designLibrary = DesignLibrary(bundle: bundle)

        let selectedCurrencyPairsService = DatafileSelectedCurrencyPairsService(
            url: FileManager.default.documentsDir.appendingPathComponent("selected.json"),
            queue: DispatchQueue(label: "selected currency pair service queue", qos: .background)
        )

        let supportedCurrenciesService = DatafileSupportedCurrenciesService(
            url: Bundle.main.url(forResource: "currencies", withExtension: "json")!,
            queue: DispatchQueue(label: "supported currencies service queue", qos: .background)
        )

        let root = ConverterFactory(
            bundle: bundle,
            designLibrary: designLibrary,
            selectedCurrencyPairsService: selectedCurrencyPairsService,
            supportedCurrenciesService: supportedCurrenciesService
        ).makeRoot()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = root
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

}

