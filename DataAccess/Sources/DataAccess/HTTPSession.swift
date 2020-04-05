import Foundation
import Future

#if canImport(Combine)
public protocol HTTPSession {
    func get(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}
extension URLSession: HTTPSession {
    public func get(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: url).eraseToAnyPublisher()
    }
}
#else
public protocol HTTPSession {
    func get(url: URL) -> Future<(Data?, URLResponse?), Error>
}

extension URLSession: HTTPSession {
    public func get(url: URL) -> Future<(Data?, URLResponse?), Error> {
        Future { promise in
            self.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success((data, response)))
                }
            }).resume()
        }
    }
}
#endif
