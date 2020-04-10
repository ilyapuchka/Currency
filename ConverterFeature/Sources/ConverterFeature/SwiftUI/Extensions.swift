import SwiftUI
import Combine

@dynamicMemberLookup
public protocol ObservableViewState: ObservableObject {
    associatedtype State
    var state: State { get }
}

extension ObservableViewState {
    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        state[keyPath: keyPath]
    }
}

extension View {
    public func sheet<Content>(isPresented: @autoclosure @escaping () -> Bool, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        sheet(isPresented: Binding<Bool>(get: isPresented, set: { _ in }), onDismiss: onDismiss, content: content)
    }
}

extension View {
    func push<V: View>(isActive: Binding<Bool>, @ViewBuilder destination: () -> V) -> some View {
        ZStack {
            self
            NavigationLink(
                destination: destination(),
                isActive: isActive,
                label: { SwiftUI.EmptyView() }
            )
        }
    }
    func push<V: View>(isActive: @autoclosure @escaping () -> Bool, @ViewBuilder destination: () -> V) -> some View {
        push(isActive: Binding<Bool>(get: isActive, set: { _ in }), destination: destination)
    }
}

extension Publisher {
    public func ignoreError() -> Publishers.Catch<Self, Empty<Self.Output, Never>> {
        self.catch { _ in Empty<Self.Output, Never>() }
    }
}

extension Publisher where Output == Never {
    public func promoteValues<T>() -> Publishers.Map<Self, T> {
        self.map { _ in fatalError() }
    }
}

