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

//        let vc = UIViewController.init(nibName: nil, bundle: nil)
//        vc.view.backgroundColor = .white
//        let emptyState = EmptyStateView(bundle: bundle, designLibrary: designLibrary)
//        vc.view.addSubview(emptyState)
//        emptyState.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            emptyState.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
//            emptyState.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor),
//            emptyState.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor)
//        ])
//

        let vc = TableViewController()
        DispatchQueue.main.async {
            vc.update(sections: [
                [
                    AddCurrencyPairButtonComponent(bundle: bundle, designLibrary: designLibrary).asAnyComponent(),
                    CurrencyRowViewComponent(
                        designLibrary: designLibrary,
                        image: UIImage(named: "EUR", in: bundle, compatibleWith: nil)!,
                        code: "EUR",
                        name: "Euro").asAnyComponent()
                ]
            ])
        }

        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

}

