import Domain
import Future
import Foundation

public struct DatafileSelectedCurrencyPairsService: SelectedCurrencyPairsService {
    let dataFileService: DatafileService<[CurrencyPair]>

    public init(url: URL, queue: DispatchQueue? = nil) {
        dataFileService = DatafileService(url: url, queue: queue)
    }

    public func selectedCurrencyPairs() -> AnyPublisher<[CurrencyPair], Error> {
        dataFileService.read()
    }

    public func save(selectedPairs: [CurrencyPair]) -> AnyPublisher<Void, Error> {
        dataFileService.write(selectedPairs)
    }
}
