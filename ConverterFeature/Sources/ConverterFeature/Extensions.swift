import SwiftUI
import Combine

@dynamicMemberLookup
public protocol ObservableViewState: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    func sendAction(_ action: Action)
}

extension ObservableViewState {
    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        state[keyPath: keyPath]
    }
}

extension View {
    public func modal<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        background(
            EmptyView().sheet(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        )
    }

    public func modal<Content>(isPresented: @autoclosure @escaping () -> Bool, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modal(isPresented: Binding<Bool>(get: isPresented, set: { _ in }), onDismiss: onDismiss, content: content)
    }
    
    public func modal<Content>(isPresented: @escaping () -> Bool, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modal(isPresented: Binding<Bool>(get: isPresented, set: { _ in }), onDismiss: onDismiss, content: content)
    }
}

extension View {
    func push<V: View>(isActive: Binding<Bool>, @ViewBuilder destination: () -> V) -> some View {
        background(
            NavigationLink(
                destination: destination(),
                isActive: isActive,
                label: { EmptyView() }
            )
        )
    }

    func push<V: View>(isActive: @autoclosure @escaping () -> Bool, @ViewBuilder destination: () -> V) -> some View {
        push(isActive: Binding<Bool>(get: isActive, set: { _ in }), destination: destination)
    }

    func push<V: View>(isActive: @escaping () -> Bool, @ViewBuilder destination: () -> V) -> some View {
        push(isActive: Binding<Bool>(get: isActive, set: { _ in }), destination: destination)
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
