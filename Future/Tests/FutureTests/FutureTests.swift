import XCTest
@testable import Future

final class FutureTests: XCTestCase {
    let backgroundQueue = DispatchQueue(label: "")

    func test_syncScheduler() {
        var done: Bool = false
        let work = {
            dispatchPrecondition(condition: .onQueue(.main))
            done = true
        }

        let sync = Scheduler.sync()
        sync.schedule(work)
        XCTAssertTrue(done)
    }

    func test_mainQueueScheduler() {
        var done: Bool = false
        let work = {
            dispatchPrecondition(condition: .onQueue(.main))
            done = true
        }

        let mainQueue = Scheduler.mainQueue()
        mainQueue.schedule(work)
        XCTAssertTrue(done)

        done = false
        let workDone = expectation(description: "Work done")
        backgroundQueue.async {
            mainQueue.schedule(work)

            DispatchQueue.main.async {
                XCTAssertTrue(done)
                workDone.fulfill()
            }
        }
        XCTAssertFalse(done)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_asyncScheduler() {
        var done: Bool = false
        let backgroundQueue = DispatchQueue(label: "")
        let work = {
            dispatchPrecondition(condition: .onQueue(backgroundQueue))
            done = true
        }

        let async = Scheduler.async(queue: backgroundQueue)

        let workDone = expectation(description: "Work done")
        DispatchQueue.main.async {
            async.schedule(work)

            backgroundQueue.async {
                XCTAssertTrue(done)
                workDone.fulfill()
            }
        }

        XCTAssertFalse(done)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_syncFulfill() {
        var future: Future<Bool, String>
        var result: Result<Bool, String>?

        future = Future { promise in
            promise.fulfill(.success(true))
        }
        future.on { result = $0 }

        XCTAssertEqual(result, .success(true))
    }

    func test_asyncFulfill() {
        var future: Future<Bool, String>
        var result: Result<Bool, String>?

        let fulfillQueue = DispatchQueue(label: "fulfill queue")
        let workDone = expectation(description: "Work done")
        fulfillQueue.suspend()

        future = Future { promise in
            fulfillQueue.async {
                promise.fulfill(.success(true))
            }
        }
        future.on {
            dispatchPrecondition(condition: .onQueue(.main))
            result = $0
            workDone.fulfill()
        }

        XCTAssertNil(result)
        fulfillQueue.resume()

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, .success(true))
    }

    func test_syncObserve() {
        var future: Future<Bool, String>
        var result: Result<Bool, String>?

        let fulfillQueue = DispatchQueue(label: "fulfill queue")
        let workDone = expectation(description: "Work done")
        fulfillQueue.suspend()

        future = Future { promise in
            fulfillQueue.async {
                promise.fulfill(.success(true))
            }
        }
        future.on {
            dispatchPrecondition(condition: .onQueue(.main))
            result = $0
            workDone.fulfill()
        }

        XCTAssertNil(result)
        fulfillQueue.resume()

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, .success(true))
    }

    func test_asyncObserve() {
        var future: Future<Bool, String>
        var result: Result<Bool, String>?

        let fulfillQueue = DispatchQueue(label: "fulfill queue")
        let workDone = expectation(description: "Work done")
        fulfillQueue.suspend()

        future = Future { promise in
            fulfillQueue.async {
                promise.fulfill(.success(true))
            }
        }.observe(on: .async(queue: backgroundQueue))

        future.on {
            dispatchPrecondition(condition: .onQueue(self.backgroundQueue))
            result = $0
            workDone.fulfill()
        }

        XCTAssertNil(result)
        fulfillQueue.resume()

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, .success(true))
    }

    func test_map() {
        var future: Future<Bool, String>
        var result: Result<Bool, String>?
        var mappedResult: Result<String, String>?

        future = Future { promise in
            promise.fulfill(.success(true))
        }
        future
            .on { result = $0 }
            .map { String(describing: $0) }
            .on { mappedResult = $0 }

        XCTAssertEqual(result, .success(true))
        XCTAssertEqual(mappedResult, .success("true"))
    }

    func test_flatMap() {
        var future: Future<Bool, String>
        var result: Result<Bool, String>?
        var mappedResult: Result<String, String>?

        future = Future { promise in
            promise.fulfill(.success(true))
        }
        future
            .on { result = $0 }
            .flatMap { value in
                Future { promise in
                    promise.fulfill(.success("\(value)"))
                }
            }
            .on { mappedResult = $0 }

        XCTAssertEqual(result, .success(true))
        XCTAssertEqual(mappedResult, .success("true"))
    }
}

extension String: Error {}
