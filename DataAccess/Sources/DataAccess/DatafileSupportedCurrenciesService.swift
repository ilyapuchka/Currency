import Future
import Domain
import Foundation
import UIKit

public struct DatafileSupportedCurrenciesService: SupportedCurrenciesService {
    let dataFileService: DatafileService<[String]>

    public init(url: URL, queue: DispatchQueue? = nil) {
        dataFileService = DatafileService(url: url, queue: queue)
    }

    #if canImport(Combine)
    public func supportedCurrencies() -> AnyPublisher<[Currency], Swift.Error> {
        dataFileService.read().map { $0.map(Currency.init(code:)) }.eraseToAnyPublisher()
    }
    #else
    public func supportedCurrencies() -> Future<[Currency], Swift.Error> {
        dataFileService.read().map { $0.map(Currency.init(code:)) }
    }
    #endif
}
