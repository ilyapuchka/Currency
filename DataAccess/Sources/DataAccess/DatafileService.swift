import Foundation
import Future

public enum DatafileServiceError: Swift.Error {
    case fileNotReadable
    case failedToWrite
}

public struct DatafileService<T> {
    let path: String
    let queue: DispatchQueue?

    public init(path: String, queue: DispatchQueue? = nil) {
        self.path = path
        self.queue = queue
    }

}

extension DatafileService where T: Decodable {
    public func read() -> Future<T, Swift.Error> {
        Future(scheduler: self.queue.map(Scheduler.async(queue:))) { [path] (promise) in
            DispatchQueue.main.async {
                guard let data = FileManager.default.contents(atPath: path) else {
                    return promise.fulfill(.failure(DatafileServiceError.fileNotReadable))
                }
                promise.fulfill(
                    Result {
                        try JSONDecoder().decode(T.self, from: data)
                    }
                )
            }
        }
    }
}

extension DatafileService where T: Encodable {
    public func write(_ value: T) -> Future<Void, Swift.Error> {
        Future(scheduler: self.queue.map(Scheduler.async(queue:))) { [path] (promise) in
            DispatchQueue.main.async {
                promise.fulfill(
                    Result {
                        let data = try JSONEncoder().encode(value)
                        guard FileManager.default.createFile(atPath: path, contents: data) else {
                            throw DatafileServiceError.failedToWrite
                        }
                    }
                )
            }
        }
    }
}
