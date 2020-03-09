import Foundation
import DataAccess
import Domain
import Future

#if DEBUG
/// Service to be used with automation tests only
struct UserDefaultsSelectedCurrencyPairsService: SelectedCurrencyPairsService {
    static let userDefaultsKey = "selected_pairs"
    init() {}

    func selectedCurrencyPairs() -> Future<[CurrencyPair], Error> {
        return Future { promise in
            promise.fulfill(
                Result {
                    guard let string = UserDefaults.standard.string(forKey: Self.userDefaultsKey), !string.isEmpty else {
                        return []
                    }

                    let pairs = string.components(separatedBy: ",").map { code -> CurrencyPair in
                        let key = CurrencyPairCodingKey(stringValue: code)!
                        return CurrencyPair(from: Currency(code: key.from), to: Currency(code: key.to))
                    }
                    return pairs
                }
            )
        }
    }

    func save(selectedPairs: [CurrencyPair]) -> Future<Void, Error> {
        // Do not persist to user default to ensure reproducible tests
        .just(())
    }
}
#endif
