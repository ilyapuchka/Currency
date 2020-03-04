import UIKit
import Future
import Domain

struct RootFlowController {
    private weak var modal: UIViewController?

    typealias MakeAddCurrencyPair = (_ disabled: [CurrencyPair], _ selected: Promise<CurrencyPair?, Never>) -> UIViewController
    private let addPair: MakeAddCurrencyPair

    init(
        modal: UIViewController,
        addPair: @escaping MakeAddCurrencyPair
    ) {
        self.modal = modal
        self.addPair = addPair
    }

    func addPair(disabled: [CurrencyPair], selected: Promise<CurrencyPair?, Never>) {
        modal?.present(addPair(disabled, selected), animated: true, completion: nil)

        Future(promise: selected).observe(on: .mainQueue()).on { [modal] (_) in
            modal?.dismiss(animated: true, completion: nil)
        }
    }
}
