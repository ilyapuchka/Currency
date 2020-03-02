import Foundation
import Domain

public struct CurrencyPairs: Codable, Equatable {
    public let pairs: [ExchangeRate]

    init(pairs: [ExchangeRate]) {
        self.pairs = pairs
    }

    public struct CodingKeys: CodingKey {
        public let stringValue: String
        public let intValue: Int? = nil

        public init?(stringValue: String) {
            self.stringValue = stringValue
        }

        public init?(intValue: Int) {
            return nil
        }

        // for simplicity assume that currency codes are always 3 characters long and pair is 6 characters
        var from: String { String(stringValue.prefix(3)) }
        var to: String { String(stringValue.suffix(3)) }

        init(from: Currency, to: Currency) {
            self.stringValue = "\(from.code)\(to.code)"
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.pairs = try values.allKeys.compactMap { key in
            // Decimal seem to be decoded as Double so looses precision sometimes
            // https://forums.swift.org/t/parsing-decimal-values-from-json/6906/8
            // https://blog.skagedal.tech/2017/12/30/decimal-decoding.html
            guard let rate = try Decimal(string: "\(values.decode(Double.self, forKey: key))") else {
                return nil
            }
            return ExchangeRate(
                from: Currency(code: key.from),
                to: Currency(code: key.to),
                rate: rate
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try self.pairs.forEach {
            try values.encode($0.rate, forKey: CodingKeys(from: $0.from, to: $0.to))
        }
    }
}
