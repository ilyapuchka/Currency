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

    lazy var sut = CurrencyPairSelectorViewController(
        viewModel: viewModel,
        config: .init(
            bundle: bundle,
            designLibrary: designLibrary,
            onDismiss: onDismiss
        )
    )

    func test_renders_currencies_list() throws {
        let state = CurrencyPairSelectorState(
            supported: supported,
            disabled: disabled,
            selected: selected,
            status: .selectingSecondCurrency(first: supported[1])
        )
        let component = sut.render(state: state, sendAction: viewModel.sendAction)
        let host: HostViewComponent<ModifiedComponent> = try component.unwrap()
        let hosted: TableViewComponent = try XCTUnwrap(host.component.unwrap())
        let sections = hosted.adapter.sections

        XCTAssertEqual(sections.count, 1)

        let rows = sections[0]
        XCTAssertEqual(rows.count, 2)

        func assertRowConfigured(index: Int, isEnabled: Bool, line: UInt = #line) throws {
            let row: CurrencyViewComponent = try rows[index].unwrap()
            XCTAssertEqual(row.code, supported[index].code, line: line)
            XCTAssertEqual(row.isEnabled, isEnabled, line: line)

            row.action()
            if case let .selected(selected)? = viewModel.receivedActions.last {
                XCTAssertEqual(selected, supported[index], line: line)
            } else {
                XCTFail("Action not configured", line: line)
            }
        }

        try assertRowConfigured(index: 0, isEnabled: true)
        try assertRowConfigured(index: 1, isEnabled: false)
    }

    func test_fulfills_onDismissPromise() {
        var onDismissCalled = false
        onDismiss.observe { _ in
            onDismissCalled = true
        }
        sut.presentationControllerDidDismiss(UIPresentationController(presentedViewController: sut, presenting: nil))

        XCTAssertTrue(onDismissCalled)
    }
}
