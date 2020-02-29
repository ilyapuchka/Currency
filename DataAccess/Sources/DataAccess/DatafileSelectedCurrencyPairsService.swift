import Domain
import Future
import Foundation

struct DatafileSelectedCurrencyPairsService: SelectedCurrencyPairsService {
    let dataFileService: DatafileService<CurrencyPairs>

    public init(path: String, queue: DispatchQueue? = nil) {
        dataFileService = DatafileService(path: path, queue: queue)
    }

    func selectedCurrencyPairs() -> Future<[CurrencyPair], Error> {
        dataFileService.read().map { $0.pairs }
    }

    func save(selectedPairs: [CurrencyPair]) -> Future<Void, Error> {
        dataFileService.write(CurrencyPairs(pairs: selectedPairs))
    }
}
