import SwiftUI
import Combine

extension Subscribers.Sink {
    convenience init(_ sink: @escaping (Input) -> Void) {
        self.init(receiveCompletion: { _ in }, receiveValue: sink)
    }
}

extension View {
    public func modal<V: View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> V) -> some View {
        background(
            EmptyView().sheet(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        )
    }

    func push<V: View>(isActive: Binding<Bool>, @ViewBuilder destination: () -> V) -> some View {
        background(
            NavigationLink(
                destination: destination(),
                isActive: isActive,
                label: { EmptyView() }
            )
        )
    }
}

extension Publisher {
    public func ignoreError() -> Publishers.Catch<Self, Empty<Self.Output, Never>> {
        self.catch { _ in Empty<Self.Output, Never>() }
    }

    public func mapError(_ transform: @escaping (Failure) -> Output) -> Publishers.Catch<Self, Just<Self.Output>> {
        self.catch { Just(transform($0)) }
    }
}

extension Publisher where Output == Never {
    public func promoteValues<T>() -> Publishers.Map<Self, T> {
        .init(upstream: self, transform: { _ in () as! T })
    }
}

extension Publisher where Failure == Never {
    public func promoteErrors<T: Error>() -> Publishers.MapError<Self, T> {
        Publishers.MapError(upstream: self, transform: { _ in () as! T })
    }
}
