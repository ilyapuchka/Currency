import XCTest
import UIKit
@testable import DesignLibrary

private var renderedLabel: Bool = false
private var renderedButton: Bool = false

struct LabelComponent: Component {
    func makeView() -> UILabel {
        UILabel()
    }
    func render(in view: UILabel) {
        renderedLabel = true
    }
}

struct ButtonComponent: Component {
    func makeView() -> UIButton {
        UIButton()
    }
    func render(in view: UIButton) {
        renderedButton = true
    }
}

final class ComponentTests: XCTestCase {
    func test_render_any_component() {
        let label = LabelComponent()
        let button = ButtonComponent()

        let all = [
            label.asAnyComponent(),
            button.asAnyComponent()
        ]

        var view = all[0].makeView()
        XCTAssertTrue(type(of: view) == all[0].viewType)
        all[0].render(in: view)

        XCTAssertTrue(renderedLabel)

        view = all[1].makeView()
        XCTAssertTrue(type(of: view) == all[1].viewType)
        all[1].render(in: view)

        XCTAssertTrue(renderedButton)
    }

    func test_hostViewComponent_reusesSubview() {
        let host = UIView()
        let component1 = HostViewComponent(host: host, alignment: .center) {
            ButtonComponent().accessibility(identifier: "accessible")
        }

        let button1 = component1.makeView()
        component1.render(in: button1)

        XCTAssertTrue(button1.superview === host, "Component should be added to the host view")

        let button2 = component1.makeView()
        XCTAssertTrue(button1 === button2, "Component view should be reused")

        let component2 = HostViewComponent(host: host, alignment: .center) {
            LabelComponent()
        }

        let label1 = component2.makeView()
        component2.render(in: label1)

        XCTAssertNil(button1.superview, "Previous component view should be removed from host view")
        XCTAssertTrue(label1.superview === host, "Component should be added to the host view")
    }

    func test_tableViewAdapter() {
        let sections = [[
            ButtonComponent().accessibility(identifier: "accessible").asAnyComponent(),
            LabelComponent().asAnyComponent()
        ]]

        let component = TableViewComponent(sections: sections)
        let tableView = component.makeView()

        component.adapter.tableView = tableView
        XCTAssertTrue(tableView.delegate === component.adapter)
        XCTAssertTrue(tableView.dataSource === component.adapter)
        
        XCTAssertEqual(component.adapter.numberOfSections(in: tableView), 1)
        XCTAssertEqual(component.adapter.tableView(tableView, numberOfRowsInSection: 0), 2)

        let cell1 = component.adapter.tableView(tableView, cellForRowAt: IndexPath.init(row: 0, section: 0)) as? ComponentCell
        let button1 = cell1?.contentView.subviews.first as? UIButton
        XCTAssertNotNil(button1)

        let button2 = cell1?.mount(component: ButtonComponent().asAnyComponent())
        XCTAssertTrue(button1 === button2, "Component view should be reused")

        _ = cell1?.mount(component: LabelComponent().asAnyComponent())
        XCTAssertNil(button1?.superview, "Previous component view should be removed from view")

        let cell2 = component.adapter.tableView(tableView, cellForRowAt: IndexPath.init(row: 1, section: 0))
        let label1 = cell2.contentView.subviews.first as? UILabel
        XCTAssertNotNil(label1)
    }
}
