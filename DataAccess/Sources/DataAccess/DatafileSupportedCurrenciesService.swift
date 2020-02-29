import Future
import Domain
import Foundation
import UIKit

public struct DatafileSupportedCurrenciesService: SupportedCurrenciesService {
    let dataFileService: DatafileService<[String]>

    public init(path: String, queue: DispatchQueue? = nil) {
        dataFileService = DatafileService(path: path, queue: queue)
    }

    public func supportedCurrencies() -> Future<[Currency], Swift.Error> {
        dataFileService.read().map { $0.map(Currency.init(code:)) }
    }
}
