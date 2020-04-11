import Foundation
@_exported import Combine

public typealias Future<T, E: Error> = Combine.Future<T, E>

extension Future {
    public static func async<S: Scheduler>(
        on scheduler: S?,
        _ attemptToFulfill: @escaping (@escaping Future<Output, Failure>.Promise) -> Void
    ) -> AnyPublisher<Output, Failure> {
        scheduler.map { scheduler in
            Self { promise in
                scheduler.schedule { attemptToFulfill(promise) }
            }.eraseToAnyPublisher()
        } ?? Self(attemptToFulfill).eraseToAnyPublisher()
    }
}

public typealias Promise<T, E: Error> = Future<T, E>.Promise
