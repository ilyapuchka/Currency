import UIKit
import Future
import Domain

struct RootFlowController {
    private weak var modal: UIViewController?

    /**
    - returns: A view controller to present to select a first currency in a pair
     - parameters:
         - disabled: already selected currency pairs that won't be enabled for selection
         - selected: a promise that will be fulfilled with the CurrencyPair when the second currency is selected or with nil if screen is dismissed
     */
    typealias MakeAddCurrencyPair = (_ disabled: [CurrencyPair], _ selected: Promise<CurrencyPair?, Never>) -> UIViewController
    private let addPair: MakeAddCurrencyPair

    /**
     - parameters:
         - modal: a view controller used for modal presentation
         - addPair: a closure that creates a screen to select the first currency in a pair
     */
    init(
        modal: UIViewController,
        addPair: @escaping MakeAddCurrencyPair
    ) {
        self.modal = modal
        self.addPair = addPair
    }

    /**
    Presents a screen to choose a first currency in a pair
     - parameters:
         - disabled: already selected currency pairs that won't be enabled for selection
         - selected: a promise that will be fulfilled with the CurrencyPair when the second currency is selected or with nil if screen is dismissed
     */
    func addPair(disabled: [CurrencyPair], selected: Promise<CurrencyPair?, Never>) {
        modal?.present(addPair(disabled, selected), animated: true, completion: nil)

        Future(promise: selected).observe(on: .mainQueue()).on { [modal] (_) in
            modal?.dismiss(animated: true, completion: nil)
        }
    }
}
