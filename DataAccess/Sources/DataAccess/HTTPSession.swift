import Foundation
import Future

public protocol HTTPSession {
    func get(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: HTTPSession {
    public func get(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: url).eraseToAnyPublisher()
    }
}
