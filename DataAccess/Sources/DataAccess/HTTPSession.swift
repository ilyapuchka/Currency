import Foundation
import Future

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
