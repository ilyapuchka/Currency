import SwiftUI

public struct When<TrueContent: View, FalseContent: View>: View {
    let condition: Bool
    let first: TrueContent
    let second: FalseContent

    public init(
        _ condition: Bool,
        @ViewBuilder
        then first: () -> TrueContent,
        @ViewBuilder
        else second: () -> FalseContent
    ) {
        self.condition = condition
        self.first = first()
        self.second = second()
    }

    public init<T, ValueContent: View>(
        _ value: T?,
        @ViewBuilder
        then first: (T) -> ValueContent,
        @ViewBuilder
        else second: () -> FalseContent
    ) where TrueContent == Optional<ValueContent> {
        self.condition = value != nil
        self.first = value.map(first)
        self.second = second()
    }

    public var body: some View {
        ViewBuilder.buildBlock(
            condition
                ? ViewBuilder.buildEither(first: first)
                : ViewBuilder.buildEither(second: second)
        )
    }
}

extension View {
    public func when<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        @ViewBuilder
        then first: @escaping (Self) -> TrueContent,
        @ViewBuilder
        else second: @escaping (Self) -> FalseContent
    ) -> some View {
        When(condition, then: { first(self) }, else: { second(self) })
    }

    public func when<TrueContent: View>(
        _ condition: Bool,
        @ViewBuilder
        then first: @escaping (Self) -> TrueContent
    ) -> some View {
        When(condition, then: { first(self) }, else: { self })
    }

    public func when<T, TrueContent: View, FalseContent: View>(
        _ condition: T?,
        @ViewBuilder
        then first: @escaping (Self, T) -> TrueContent,
        @ViewBuilder
        else second: @escaping (Self) -> FalseContent
    ) -> some View {
        When(condition, then: { first(self, $0) }, else: { second(self) })
    }

    public func when<T, TrueContent: View>(
        _ condition: T?,
        @ViewBuilder
        then first: @escaping (Self, T) -> TrueContent
    ) -> some View {
        When(condition, then: { first(self, $0) }, else: { self })
    }
}
