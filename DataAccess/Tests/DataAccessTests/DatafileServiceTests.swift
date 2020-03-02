import XCTest
import DataAccess
import Domain

final class DatafileServiceTests: XCTestCase {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("supported_currencies.json")

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: url)
    }

    func test_can_read_from_file() throws {
        let data = """
        [
            "ABC",
            "DEF"
        ]
        """.data(using: .utf8)!

        try data.write(to: url, options: .atomic)

        let sut = DatafileService<[String]>(url: url)
        var result: [String]?

        let done = expectation(description: "")
        sut.read().on {
            result = try? $0.get()
            done.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(result, ["ABC", "DEF"])
    }

    func test_throws_error_on_invalid_path() {
        let url = URL(string: "some")!
        let sut = DatafileService<[String]>(url: url)

        var error: Error?
        let done = expectation(description: "")
        sut.read().on {
            if case let .failure(_error) = $0 {
                error = _error
            }
            done.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(error)
    }

    func test_throws_error_on_invalid_content() throws {
        let data = "".data(using: .utf8)!

        try data.write(to: url, options: .atomic)

        let sut = DatafileService<[String]>(url: url)

        var error: DecodingError?
        let done = expectation(description: "")
        sut.read().on {
            if case let .failure(_error as DecodingError) = $0 {
                error = _error
            }
            done.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        guard case .dataCorrupted = try XCTUnwrap(error) else {
            return XCTFail("Unexpected error")
        }
    }

    func test_can_write_to_file() {
        let sut = DatafileService<[String]>(url: url)

        var result: Void?
        var done = expectation(description: "")
        sut.write(["ABC", "DEF"]).on {
            result = try? $0.get()
            done.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(result)

        done = expectation(description: "")
        sut.read().on {
            XCTAssertEqual(try? $0.get(), ["ABC", "DEF"])
            done.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
