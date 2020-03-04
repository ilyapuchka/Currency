import UIKit
import Future
import Domain

struct CurrencyPairSelectorFlowController {
    weak var navigation: UINavigationController?

    /**
     - returns: A view controller to present to select a second currency in a pair
     - parameters:
        - first: first currency in a pair
        - disabled: already selected currency pairs that won't be enabled for selection
        - selected: a promise that will be fulfilled with the CurrencyPair when the second currency is selected or with nil if screen is dismissed
     */
    typealias MakeSecondCurrencySelector = (_ first: Currency, _ disabled: [CurrencyPair], _ selected: Promise<CurrencyPair?, Never>) -> UIViewController
    let makeSecond: MakeSecondCurrencySelector

    /**
    - parameters:
        - navigation: navigation controller used for presentation
        - makeSecond: a closure that creates a screen to select second currency in a pair
     */
    init(
        navigation: UINavigationController,
        makeSecond: @escaping MakeSecondCurrencySelector
    ) {
        self.navigation = navigation
        self.makeSecond = makeSecond
    }

    /**
     Present the screen to select the second currency in a pair
     - parameters:
        - first: first currency in a pair
        - disabled: already selected currency pairs that won't be enabled for selection
        - selected: a promise that will be fulfilled with the CurrencyPair when the second currency is selected or with nil if screen is dismissed
     */
    func selectSecond(first: Currency, disabled: [CurrencyPair], selected: Promise<CurrencyPair?, Never>) -> Void {
        navigation?.pushViewController(makeSecond(first, disabled, selected), animated: true)
    }
}
