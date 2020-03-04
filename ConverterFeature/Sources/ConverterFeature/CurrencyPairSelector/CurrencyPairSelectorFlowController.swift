import UIKit
import Future
import Domain

struct CurrencyPairSelectorFlowController {
    weak var navigation: UINavigationController?

    typealias MakeSecondCurrencySelector = (_ first: Currency, _ disabled: [CurrencyPair], _ selected: Promise<CurrencyPair?, Never>) -> UIViewController
    let makeSecond: MakeSecondCurrencySelector
    init(
        navigation: UINavigationController,
        makeSecond: @escaping MakeSecondCurrencySelector
    ) {
        self.navigation = navigation
        self.makeSecond = makeSecond
    }

    func selectSecond(first: Currency, disabled: [CurrencyPair], selected: Promise<CurrencyPair?, Never>) -> Void {
        navigation?.pushViewController(makeSecond(first, disabled, selected), animated: true)
    }
}
