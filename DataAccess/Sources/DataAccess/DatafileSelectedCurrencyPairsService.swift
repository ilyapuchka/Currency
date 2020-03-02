import Domain
import Future
import Foundation

public struct DatafileSelectedCurrencyPairsService: SelectedCurrencyPairsService {
    let dataFileService: DatafileService<CurrencyPairs>

    public init(url: URL, queue: DispatchQueue? = nil) {
        dataFileService = DatafileService(url: url, queue: queue)
    }

    public func selectedCurrencyPairs() -> Future<[ExchangeRate], Error> {
        dataFileService.read().map { $0.pairs }
    }

    public func save(selectedPairs: [ExchangeRate]) -> Future<Void, Error> {
        dataFileService.write(CurrencyPairs(pairs: selectedPairs))
    }
}
