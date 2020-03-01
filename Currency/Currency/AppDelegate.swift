import UIKit
import ConverterFeature
import DesignLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        let bundle = Bundle(for: Self.self)
        let designLibrary = DesignLibrary(bundle: bundle)

        let vc = UIViewController.init(nibName: nil, bundle: nil)
        vc.view.backgroundColor = .white
        let emptyState = EmptyStateView(bundle: bundle, designLibrary: designLibrary)
        vc.view.addSubview(emptyState)
        emptyState.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyState.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            emptyState.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor)
        ])

        window.rootViewController = vc

//        window.rootViewController = ViewController(
//            bundle: bundle,
//            designLibrary: designLibrary
//        )
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

}

