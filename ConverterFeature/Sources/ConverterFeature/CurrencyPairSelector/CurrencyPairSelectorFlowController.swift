import UIKit
import Future
import Domain

struct CurrencyPairSelectorFlowController {
    let navigation: UINavigationController
    let makeSecond: (Currency, Promise<CurrencyPair?, Never>) -> UIViewController

    init(
        navigation: UINavigationController,
        makeSecond: @escaping (Currency, Promise<CurrencyPair?, Never>) -> UIViewController
    ) {
        self.navigation = navigation
        self.makeSecond = makeSecond
    }

    func selectSecond(first: Currency, selected: Promise<CurrencyPair?, Never>) -> Void {
        navigation.pushViewController(makeSecond(first, selected), animated: true)
    }
}
