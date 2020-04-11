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
