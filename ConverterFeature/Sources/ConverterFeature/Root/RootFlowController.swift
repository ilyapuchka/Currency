import UIKit
import Future
import Domain

struct RootFlowController {
    let modal: UIViewController

    typealias MakeAddCurrencyPair = (_ disabled: [CurrencyPair], _ selected: Promise<CurrencyPair?, Never>) -> UIViewController
    let addPair: MakeAddCurrencyPair

    init(
        modal: UIViewController,
        addPair: @escaping MakeAddCurrencyPair
    ) {
        self.modal = modal
        self.addPair = addPair
    }

    func addPair(disabled: [CurrencyPair], promise: Promise<CurrencyPair?, Never>) {
        modal.present(addPair(disabled, promise), animated: true, completion: nil)

        Future(promise: promise).observe(on: .mainQueue()).on { [modal] (_) in
            modal.dismiss(animated: true, completion: nil)
        }
    }
}
