import Foundation
import Domain

public protocol ExchangeRateFormatter {
    /// Returns formatted string for amount in `rate.from` currency
    func formatFrom(rate: ExchangeRate) -> String

    /// Returns formatted string for amount in `rate.to` currency
    func formatTo(rate: ExchangeRate) -> String

    /// Returns formatted accessibility label for exchange rate
    func accessibleFormat(rate: ExchangeRate) -> String
}

public struct LocalizedExchangeRateFormatter: ExchangeRateFormatter {
    let bundle: Bundle

    public init(bundle: Bundle = .main, locale: Locale = Locale.current) {
        self.bundle = bundle
        self.numberFormatter.locale = locale
    }

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.maximumFractionDigits = 4
        return formatter
    }()

    public func formatFrom(rate: ExchangeRate) -> String {
        return formatAmount(1, minimumFractionDigits: 0, label: rate.pair.from.code)
    }

    public func formatTo(rate: ExchangeRate) -> String {
        return formatAmount(rate.convert(amount: 1), minimumFractionDigits: 4, label: rate.pair.to.code)
    }

    private func formatAmount(_ amount: Decimal, minimumFractionDigits: Int = 0, label: String) -> String {
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        return String.nonLeakingString(
            format: NSLocalizedString("exchange_rate_format", bundle: bundle, comment: ""),
            numberFormatter.string(for: amount) ?? "\(amount)",
            label
        )
    }

    public func accessibleFormat(rate: ExchangeRate) -> String {
        let fromLocalizedDescription = NSLocalizedString(rate.pair.from.code, bundle: bundle, comment: "")
        let toLocalizedDescription = NSLocalizedString(rate.pair.to.code, bundle: bundle, comment: "")

        return String.nonLeakingString(
            format: NSLocalizedString("accessible_exchange_rate_format", bundle: bundle, comment: ""),
            formatAmount(1, label: fromLocalizedDescription),
            formatAmount(rate.convert(amount: 1), minimumFractionDigits: 4, label: toLocalizedDescription)
        )
    }
}

extension String {
    // There seem to be a bug related to leaking CFString when using String(format:args:)
    // At least memory graph debugger shows strings leaking
    // Workaround that by using NSString directly, this makes memory graph debugger happy
    // Might be also related to https://bugs.swift.org/browse/SR-4036
    static func nonLeakingString(format: String, _ args: CVarArg...) -> String {
        let result = withVaList(args) {
            NSString(format: format, arguments: $0)
        }
        return "\(result)"
    }
}
