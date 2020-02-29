import XCTest
import DataAccess
import Domain

final class DatafileServiceTests: XCTestCase {
    func test_can_read_from_file() {
        let bundle = Bundle.init(for: type(of: self))
        let path = bundle.bundlePath + "/supported_currencies.json"
        let data = """
        [
            "ABC",
            "DEF"
        ]
        """.data(using: .utf8)!

        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)

        let sut = DatafileService<[String]>(path: path)
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
        let sut = DatafileService<[String]>(path: "")

        var error: DatafileServiceError?
        let done = expectation(description: "")
        sut.read().on {
            if case let .failure(_error as DatafileServiceError) = $0 {
                error = _error
            }
            done.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(error, .fileNotReadable)
    }

    func test_throws_error_on_invalid_content() throws {
        let bundle = Bundle.init(for: type(of: self))
        let path = bundle.bundlePath + "/supported_currencies.json"
        let data = "".data(using: .utf8)!

        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)

        let sut = DatafileService<[String]>(path: path)

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
        let bundle = Bundle.init(for: type(of: self))
        let path = bundle.bundlePath + "/supported_currencies.json"

        let sut = DatafileService<[String]>(path: path)

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
