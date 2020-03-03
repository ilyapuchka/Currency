import UIKit
import Future
import Domain

struct CurrencyPairSelectorFlowController {
    let navigation: UINavigationController
    let makeSecond: (Currency, [Currency], Promise<CurrencyPair?, Never>) -> UIViewController

    init(
        navigation: UINavigationController,
        makeSecond: @escaping (Currency, [Currency], Promise<CurrencyPair?, Never>) -> UIViewController
    ) {
        self.navigation = navigation
        self.makeSecond = makeSecond
    }

    func selectSecond(first: Currency, disabled: [Currency], selected: Promise<CurrencyPair?, Never>) -> Void {
        navigation.pushViewController(makeSecond(first, disabled, selected), animated: true)
    }
}
