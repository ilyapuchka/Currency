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
}
