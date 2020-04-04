import Foundation
import Future

public extension FileManager {
    var documentsDir: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

public struct DatafileService<T> {
    let url: URL
    let queue: DispatchQueue?

    public init(url: URL, queue: DispatchQueue? = nil) {
        self.url = url
        self.queue = queue
    }

}

#if canImport(Combine)
extension DatafileService where T: Decodable {
    public func read() -> Future<T, Swift.Error> {
        fatalError()
    }
}
extension DatafileService where T: Encodable {
    public func write(_ value: T) -> Future<Void, Swift.Error> {
        fatalError()
    }
}
#else
extension DatafileService where T: Decodable {
    public func read() -> Future<T, Swift.Error> {
        Future(scheduler: self.queue.map(Scheduler.async(queue:))) { [url] (promise) in
            DispatchQueue.main.async {
                promise.fulfill(
                    Result {
                        let data = try Data(contentsOf: url)
                        return try JSONDecoder().decode(T.self, from: data)
                    }
                )
            }
        }
    }
}

extension DatafileService where T: Encodable {
    public func write(_ value: T) -> Future<Void, Swift.Error> {
        Future(scheduler: self.queue.map(Scheduler.async(queue:))) { [url] (promise) in
            DispatchQueue.main.async {
                promise.fulfill(
                    Result {
                        let data = try JSONEncoder().encode(value)
                        try data.write(to: url, options: .atomic)
                    }
                )
            }
        }
    }
}
#endif
