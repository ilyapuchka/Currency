import Foundation
import Domain

public struct CurrencyPairs: Decodable, Equatable {
    public let pairs: [CurrencyPair]

    init(pairs: [CurrencyPair]) {
        self.pairs = pairs
    }

    struct CodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int? = nil

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.pairs = try values.allKeys.map { key in
            try values.decode(CurrencyPair.self, forKey: key)
        }
    }
}

extension KeyedDecodingContainer {
    public func decode(_ type: CurrencyPair.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> CurrencyPair {
        let rate = try self.decode(Decimal.self, forKey: key)
        // for simplicity assume that currency codes are always 3 characters long and pair is 6 characters
        let from = String(key.stringValue.prefix(3))
        let to = String(key.stringValue.suffix(3))
        return CurrencyPair(from: Currency(code: from), to: Currency(code: to), rate: rate)
    }
}
