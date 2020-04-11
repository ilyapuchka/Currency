import Foundation
import DataAccess
import Domain
import Future
import ConverterFeature

#if DEBUG
struct UserDefaultsSelectedCurrencyPairsService: SelectedCurrencyPairsService {
    static let userDefaultsKey = "selected_pairs"
    init() {}

    func selectedCurrencyPairs() -> AnyPublisher<[CurrencyPair], Error> {
        return Future { promise in
            promise(
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
        }.eraseToAnyPublisher()
    }

    func save(selectedPairs: [CurrencyPair]) -> AnyPublisher<Void, Error> {
        // Do not persist to user default to ensure reproducible tests
        Just(()).promoteErrors().eraseToAnyPublisher()
    }
}
#endif
