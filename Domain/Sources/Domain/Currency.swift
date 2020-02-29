public struct Currency: Equatable, ExpressibleByStringLiteral {
    public let code: String

    public init(code: String) {
        self.code = code
    }

    public init(stringLiteral value: String) {
        self.init(code: value)
    }
}
