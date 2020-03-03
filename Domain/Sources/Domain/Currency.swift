public struct Currency: Equatable, Hashable, ExpressibleByStringLiteral {
    public let code: String

    public init(code: String) {
        self.code = code
    }

    public init(stringLiteral value: String) {
        self.init(code: value)
    }
}
