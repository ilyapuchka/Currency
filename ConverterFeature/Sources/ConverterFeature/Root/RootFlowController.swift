import UIKit
import Future
import Domain

struct RootFlowController {
    let modal: UIViewController
    let addPair: ([Currency], Promise<CurrencyPair?, Never>) -> UIViewController

    init(
        modal: UIViewController,
        addPair: @escaping ([Currency], Promise<CurrencyPair?, Never>) -> UIViewController
    ) {
        self.modal = modal
        self.addPair = addPair
    }

    func addPair(disabled: [Currency], promise: Promise<CurrencyPair?, Never>) {
        modal.present(addPair(disabled, promise), animated: true, completion: nil)

        Future(promise: promise).observe(on: .mainQueue()).on { [modal] (_) in
            modal.dismiss(animated: true, completion: nil)
        }
    }
}
