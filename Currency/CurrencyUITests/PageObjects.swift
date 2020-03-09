import XCTest
import Domain
import DataAccess
import DesignLibrary

struct App {
    let app: XCUIApplication
    init(app: XCUIApplication = XCUIApplication()) {
        self.app = app
        app.launchArguments = [
            "-selected_pairs"
        ]
    }

    func launchWithSelectedPairs(selectedPairs: [String]) -> RootView {
        app.launchArguments += [
            selectedPairs.joined(separator: ",")
        ]
        app.launch()
        return RootView(app: app)
    }

    func terminate() -> App {
        app.terminate()
        return self
    }

    func run(for seconds: TimeInterval) -> App {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        return self
    }
}

struct RootView {
    let app: XCUIApplication
    init(app: XCUIApplication) {
        self.app = app
    }

    func tapAddCurrencyButton() -> CurrencyList {
        app.buttons[AddCurrencyPairView.Accessibility.addCurrencyPair].waitToExist().tap()
        return CurrencyList(app: app)
    }

    func exchangeRatesList() -> XCUIElement {
        app.tables[AddCurrencyPairView.Accessibility.exchangeRatesList]
    }

    func deleteCurrency(at index: Int, file: StaticString = #file, line: UInt = #line) -> RootView {
        let cell = exchangeRatesList().cells.element(boundBy: index)

        cell.waitToExist(file: file, line: line).swipeLeft()
        cell.buttons["Delete"].waitToExist(file: file, line: line).tap()

        return self
    }

    @discardableResult
    func waitForCurrencyPairViewToExist(_ pair: String, at index: Int, file: StaticString = #file, line: UInt = #line) -> RootView {
        let cell = exchangeRatesList().cells.element(boundBy: index)
        let rate = cell.otherElements[pair]
        XCTAssertTrue(rate.waitToExist(), file: file, line: line)

        return self
    }

    @discardableResult
    func waitForCurrencyPairViewToNotExist(_ pair: String, at index: Int, file: StaticString = #file, line: UInt = #line) -> RootView {
        let cell = exchangeRatesList().cells.element(boundBy: index)
        let rate = cell.otherElements[pair]
        XCTAssertTrue(rate.waitToNotExist(), file: file, line: line)

        return self
    }

    @discardableResult
    func waitForEmptyViewToExist(file: StaticString = #file, line: UInt = #line) -> RootView {
        let emptyView = app.otherElements[EmptyStateView.Accessibility.emptyView]
        XCTAssertTrue(emptyView.waitToExist(), file: file, line: line)

        return self
    }
}

struct CurrencyList {
    let app: XCUIApplication
    init(app: XCUIApplication) {
        self.app = app
    }

    func currencyList() -> XCUIElement {
        app.tables[CurrencyView.Accessibility.currencyList]
    }

    func selectCurrency(_ code: String, file: StaticString = #file, line: UInt = #line) -> CurrencyList {
        currencyList().buttons[code].waitToExist(file: file, line: line).tap()
        return self
    }

    func selectSecondCurrency(_ code: String, file: StaticString = #file, line: UInt = #line) -> RootView {
        currencyList().buttons[code].waitToExist(file: file, line: line).tap()
        return RootView(app: app)
    }
}

extension XCUIElement {
    func waitToExist(timeout: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        XCTAssertTrue(waitToExist(timeout: timeout), file: file, line: line)
        return self
    }

    func waitToExist(timeout: TimeInterval = 5) -> Bool {
        let exists = NSPredicate(format: "exists == true")
        if exists.evaluate(with: self) { return true }
        let rateViewExists = XCTNSPredicateExpectation(predicate: exists, object: self)
        return XCTWaiter().wait(for: [rateViewExists], timeout: 5) == .completed
    }

    func waitToNotExist(timeout: TimeInterval = 5) -> Bool {
        let exists = NSPredicate(format: "exists == false")
        if exists.evaluate(with: self) { return true }
        let rateViewExists = XCTNSPredicateExpectation(predicate: exists, object: self)
        return XCTWaiter().wait(for: [rateViewExists], timeout: 5) == .completed
    }
}
