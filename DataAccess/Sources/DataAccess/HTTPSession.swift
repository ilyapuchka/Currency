import Foundation
import Future

public protocol HTTPSession {
    func get(url: URL) -> Future<(Data?, URLResponse?), Error>
}

extension URLSession: HTTPSession {
    public func get(url: URL) -> Future<(Data?, URLResponse?), Error> {
        Future { promise in
            dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    promise.fulfill(.failure(error))
                } else {
                    promise.fulfill(.success((data, response)))
                }
            }).resume()
        }
    }
}
