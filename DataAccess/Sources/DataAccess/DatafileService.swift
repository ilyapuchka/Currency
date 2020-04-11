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

extension DatafileService where T: Decodable {
    public func read() -> AnyPublisher<T, Swift.Error> {
        Future.async(on: queue) { [url] (promise) in
            promise(
                Result {
                    let data = try Data(contentsOf: url)
                    return try JSONDecoder().decode(T.self, from: data)
                }
            )
        }
    }
}

extension DatafileService where T: Encodable {
    public func write(_ value: T) -> AnyPublisher<Void, Swift.Error> {
        Future.async(on: queue) { [url] (promise) in
            promise(
                Result {
                    let data = try JSONEncoder().encode(value)
                    try data.write(to: url, options: .atomic)
                }
            )
        }
    }
}
