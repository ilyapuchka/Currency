import SwiftUI

public protocol _ConditionalView: View {
    var condition: Bool { get }
}

public struct When<TrueContent: View, FalseContent: View>: View, _ConditionalView {
    public let condition: Bool
    let first: () -> TrueContent
    let second: () -> FalseContent

    public var matched: Bool { condition }

    public init(
        _ condition: Bool,
        @ViewBuilder
        then first: @escaping () -> TrueContent,
        @ViewBuilder
        else second: @escaping () -> FalseContent
    ) {
        self.condition = condition
        self.first = first
        self.second = second
    }

    public init<T, ValueContent: View>(
        _ value: T?,
        @ViewBuilder
        then first: @escaping(T) -> ValueContent,
        @ViewBuilder
        else second: @escaping () -> FalseContent
    ) where TrueContent == Optional<ValueContent> {
        self.condition = value != nil
        self.first = { value.map(first) }
        self.second = second
    }

    public var body: some View {
        ViewBuilder.buildBlock(
            condition
                ? ViewBuilder.buildEither(first: first())
                : ViewBuilder.buildEither(second: second())
        )
    }
}

extension When where FalseContent == EmptyView {
    public init(
        _ condition: Bool,
        @ViewBuilder
        then first: @escaping () -> TrueContent
    ) {
        self.init(condition, then: first, else: { EmptyView() })
    }

    public init<T, ValueContent: View>(
        _ value: T?,
        @ViewBuilder
        then first: @escaping (T) -> ValueContent
    ) where TrueContent == Optional<ValueContent> {
        self.init(value, then: first, else: { EmptyView() })
    }

}

public struct ConditionalView<Previous: _ConditionalView, Content: View>: _ConditionalView {
    public let condition: Bool
    private let content: () -> When<When<Content, Previous>?, When<Content, EmptyView>>

    public init(condition: Bool, previous: Previous?, @ViewBuilder then content: @escaping () -> Content) {
        self.condition = condition
        self.content = {
            When(previous, then: { previous in
                When(!previous.condition, then: content, else: { previous })
            }, else: {
                When(condition, then: content, else: { EmptyView() })
            })
        }
    }

    public var body: some View {
        content()
    }
}


extension _ConditionalView {
    public func when<V: View>(_ condition: Bool, @ViewBuilder then content: @escaping () -> V) -> ConditionalView<Self, V> {
        ConditionalView(condition: condition, previous: self, then: { content() })
    }
    public func when<T, V: View>(_ condition: T?, @ViewBuilder then content: @escaping (T) -> V) -> ConditionalView<Self, V> {
        self.when(condition != nil, then: { content(condition!) })
    }
    public func otherwise<V: View>(@ViewBuilder _ content: @escaping () -> V) -> some View {
        self.when(true, then: content)
    }
}
