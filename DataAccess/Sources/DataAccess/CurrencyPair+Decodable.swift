import Foundation
import Domain

public struct CurrencyPairCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int? = nil

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        return nil
    }

    // for simplicity assume that currency codes are always 3 characters long and pair is 6 characters
    public var from: String { String(stringValue.prefix(3)) }
    public var to: String { String(stringValue.suffix(3)) }

    public init(_ pair: CurrencyPair) {
        self.stringValue = "\(pair.from.code)\(pair.to.code)"
    }
}

extension CurrencyPair: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        let stringValue = try values.decode(String.self)

        let key = CurrencyPairCodingKey(stringValue: stringValue)!
        self.init(
            from: Currency(code: key.from),
            to: Currency(code: key.to)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(CurrencyPairCodingKey(self).stringValue)
    }
}

public struct ExchangeRates: Decodable, Equatable {
    public let rates: [ExchangeRate]

    init(rates: [ExchangeRate]) {
        self.rates = rates
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CurrencyPairCodingKey.self)
        self.rates = try values.allKeys.compactMap { key in
            // Decimal seem to be decoded as Double so looses precision sometimes
            // https://forums.swift.org/t/parsing-decimal-values-from-json/6906/8
            // https://blog.skagedal.tech/2017/12/30/decimal-decoding.html
            guard let rate = try Decimal(string: "\(values.decode(Double.self, forKey: key))") else {
                return nil
            }
            return ExchangeRate(
                pair: CurrencyPair(
                    from: Currency(code: key.from),
                    to: Currency(code: key.to)
                ),
                rate: rate
            )
        }
    }
}
