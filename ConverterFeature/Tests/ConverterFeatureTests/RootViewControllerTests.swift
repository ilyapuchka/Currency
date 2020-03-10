import XCTest
@testable import ConverterFeature
@testable import DesignLibrary
import Future
import Domain

final class RootViewControllerTests: XCTestCase {
    let viewModel = StubViewModel<RootState, RootEvent.UserAction>()
    let bundle = Bundle.main
    let designLibrary = DesignLibrary(bundle: .main)

    lazy var sut = RootViewController(
        viewModel: viewModel,
        config: .init(
            bundle: bundle,
            designLibrary: designLibrary,
            formatter: LocalizedExchangeRateFormatter(bundle: bundle)
        )
    )

    func test_renders_emptyState() throws {
        let state = RootState(status: .isLoaded, observeUpdates: { (_, _) in })
        let component = sut.render(state: state, sendAction: viewModel.sendAction)
        let host: HostViewComponent<ModifiedComponent> = try component.unwrap()
        let hosted: EmptyStateViewComponent = try XCTUnwrap(host.component.unwrap())

        XCTAssertEqual(hosted.actionImage, \DesignLibrary.assets.plus)
        XCTAssertEqual(hosted.actionTitle, "add_currency_pair_button_title")
        XCTAssertEqual(hosted.description, "add_currency_pair_button_subtitle")

        hosted.action()

        guard case .addPair? = viewModel.receivedActions.last else {
            return XCTFail()
        }
    }

    func test_renders_errorState() throws {
        let state = RootState(
            status: .isLoaded,
            observeUpdates: { (_, _) in },
            error: NSError(domain: "", code: 0, userInfo: nil)
        )
        let component = sut.render(state: state, sendAction: viewModel.sendAction)
        let host: HostViewComponent<ModifiedComponent> = try component.unwrap()
        let hosted: EmptyStateViewComponent = try XCTUnwrap(host.component.unwrap())

        XCTAssertNil(hosted.actionImage)
        XCTAssertEqual(hosted.actionTitle, "retry")
        XCTAssertEqual(hosted.description, "failed_to_update")

        hosted.action()

        guard case .retry? = viewModel.receivedActions.last else {
            return XCTFail()
        }
    }

    func test_renders_exchangeRates() throws {
        let formatter = StubFormatter()

        sut = RootViewController(
            viewModel: viewModel,
            config: .init(
                bundle: bundle,
                designLibrary: designLibrary,
                formatter: formatter
            )
        )

        let rate = ExchangeRate(pair: CurrencyPair(from: "EUR", to: "USD"), rate: 1.23)
        let updatedRate = ExchangeRate(pair: CurrencyPair(from: "EUR", to: "USD"), rate: 1.34)

        var observeUpdateCalled = false
        let state = RootState(
            rates: [rate],
            pairs: [CurrencyPair(from: "EUR", to: "USD")],
            status: .isLoaded,
            observeUpdates: { pair, update in
                observeUpdateCalled = true
                update(updatedRate)
            }
        )
        let component = sut.render(state: state, sendAction: viewModel.sendAction)
        let host: HostViewComponent<ModifiedComponent> = try component.unwrap()
        let hosted: TableViewComponent = try XCTUnwrap(host.component.unwrap())
        let sections = hosted.adapter.sections

        XCTAssertEqual(sections.count, 1)

        let rows = sections[0]

        XCTAssertEqual(rows.count, 2)

        let addPairButton: AddCurrencyPairViewComponent = try rows[0].unwrap()

        addPairButton.action()

        guard case .addPair? = viewModel.receivedActions.last else {
            return XCTFail()
        }

        let rateView: ExchangeRateViewComponent = try rows[1].unwrap()

        XCTAssertEqual(rateView.from.amount, "format from for \(rate)")
        XCTAssertEqual(rateView.from.description, "EUR")
        XCTAssertEqual(rateView.to.amount, "format to for \(rate)")
        XCTAssertEqual(rateView.to.description, "USD")

        rateView.onDelete()

        guard case .deletePair(CurrencyPair(from: "EUR", to: "USD"))? = viewModel.receivedActions.last else {
            return XCTFail()
        }

        rateView.onRateUpdate { rate, accessibilityLabel in
            XCTAssertEqual(rate, "format to for \(updatedRate)")
            XCTAssertEqual(accessibilityLabel, "accessible format for \(updatedRate)")
        }

        XCTAssertTrue(observeUpdateCalled)
    }
}

class StubFormatter: ExchangeRateFormatter {
    func formatFrom(rate: ExchangeRate) -> String {
        "format from for \(rate)"
    }

    func formatTo(rate: ExchangeRate) -> String {
        "format to for \(rate)"
    }

    func accessibleFormat(rate: ExchangeRate) -> String {
        "accessible format for \(rate)"
    }
}
