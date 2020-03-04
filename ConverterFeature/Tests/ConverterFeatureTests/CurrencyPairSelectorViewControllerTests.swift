import XCTest
@testable import ConverterFeature
@testable import DesignLibrary
import Future
import Domain

final class CurrencyPairSelectorViewControllerTests: XCTestCase {
    let viewModel = StubViewModel<CurrencyPairSelectorState, CurrencyPairSelectorEvent.UserAction>()
    let supported: [Currency] = ["USD", "EUR"]
    let disabled = [CurrencyPair(from: "USD", to: "EUR")]
    let selected = Promise<CurrencyPair?, Never>()
    let onDismiss = Promise<Void, Never>()
    let bundle = Bundle.main
    let designLibrary = DesignLibrary(bundle: .main)

    func test_renders_currencies_selectingFirst() throws {
        let vc = CurrencyPairSelectorViewController(
            viewModel: viewModel,
            config: .init(
                bundle: bundle,
                designLibrary: designLibrary,
                onDismiss: onDismiss
            )
        )

        let state = CurrencyPairSelectorState(
            supported: supported,
            disabled: disabled,
            selected: selected,
            status: .selectingSecondCurrency(first: supported[1])
        )
        let components = vc.render(state: state, sendAction: viewModel.sendAction)
        XCTAssertEqual(components.count, 1)

        let host = try XCTUnwrap(components[0].wrapped as? AnyComponentBox<HostViewComponent<TableViewComponent>>).wrapped
        let sections = host.component.adapter.sections

        XCTAssertEqual(sections.count, 1)

        let rows = sections[0]
        XCTAssertEqual(rows.count, 2)

        let row1 = try XCTUnwrap(rows[0].wrapped as? AnyComponentBox<CurrencyViewComponent>).wrapped
        XCTAssertEqual(row1.code, supported[0].code)
        XCTAssertEqual(row1.isEnabled, true)

        row1.action()
        if case let .selected(selected)? = viewModel.receivedActions.last {
            XCTAssertEqual(selected, supported[0])
        } else {
            XCTFail()
        }

        let row2 = try XCTUnwrap(rows[1].wrapped as? AnyComponentBox<CurrencyViewComponent>).wrapped
        XCTAssertEqual(row2.code, supported[1].code)
        XCTAssertEqual(row2.isEnabled, false)

        row2.action()
        if case let .selected(selected)? = viewModel.receivedActions.last {
            XCTAssertEqual(selected, supported[1])
        } else {
            XCTFail()
        }
    }

    func test_onDismiss() {
        let vc = CurrencyPairSelectorViewController(
            viewModel: viewModel,
            config: .init(
                bundle: bundle,
                designLibrary: designLibrary,
                onDismiss: onDismiss
            )
        )
        var onDismissCalled = false
        onDismiss.observe { _ in
            onDismissCalled = true
        }
        vc.presentationControllerDidDismiss(UIPresentationController(presentedViewController: vc, presenting: nil))

        XCTAssertTrue(onDismissCalled)
    }
}

class StubViewModel<State, UserAction>: ViewModelProtocol {
    var receivedActions: [UserAction] = []

    func sendAction(_ action: UserAction) {
        receivedActions.append(action)
    }

    func observeState(_ observer: @escaping (State) -> Void) {

    }
}

extension StubViewModel: CurrencyPairSelectorViewModelProtocol
    where
    State == CurrencyPairSelectorState,
    UserAction == CurrencyPairSelectorEvent.UserAction
{

}
