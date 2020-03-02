import UIKit
import Future
import Domain

struct RootFlowController {
    let modal: UIViewController
    let addPair: (Promise<CurrencyPair?, Never>) -> UIViewController

    init(
        modal: UIViewController,
        addPair: @escaping (Promise<CurrencyPair?, Never>) -> UIViewController
    ) {
        self.modal = modal
        self.addPair = addPair
    }

    func addPair(promise: Promise<CurrencyPair?, Never>) {
        let vc = addPair(promise)
        modal.present(vc, animated: true, completion: nil)

        promise.observe { [modal] (result) in
            modal.dismiss(animated: true, completion: nil)
        }
    }
}
