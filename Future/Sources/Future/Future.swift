import Foundation

public struct Future<Value, Error: Swift.Error> {
    public typealias Completed = (Result<Value, Error>) -> Void
    public typealias Success = (Value) -> Void
    public typealias Failure = (Error) -> Void

    let promise: Promise<Value, Error>
    let scheduler: Scheduler?

    public init(scheduler: Scheduler? = nil, _ perform: (Promise<Value, Error>) -> Void) {
        let promise = Promise<Value, Error>()
        self.init(scheduler: scheduler, promise: promise)
        perform(promise)
    }

    public init(scheduler: Scheduler? = nil, promise: Promise<Value, Error>) {
        self.scheduler = scheduler
        self.promise = promise
    }

    public func observe(on scheduler: Scheduler) -> Future {
        return Future(scheduler: scheduler, promise: promise)
    }

    @discardableResult
    public func on(success: @escaping Success, failure: Failure? = nil) -> Self {
        let scheduler = self.scheduler ?? Scheduler.mainQueue()
        promise.observe { result in
            scheduler.schedule {
                switch result {
                case let .success(value): success(value)
                case let .failure(error): failure?(error)
                }
            }
        }
        return self
    }

    @discardableResult
    public func on(completed: @escaping Completed) -> Self {
        let scheduler = self.scheduler ?? Scheduler.mainQueue()
        promise.observe { result in
            scheduler.schedule {
                completed(result)
            }
        }
        return self
    }

    public func map<T>(_ transform: @escaping (Value) -> T) -> Future<T, Error> {
        let promise = Promise<T, Error>()
        self.on(
            success: { promise.fulfill(.success(transform($0))) },
            failure: { promise.fulfill(.failure($0)) }
        )
        return Future<T, Error>(scheduler: scheduler, promise: promise)
    }

    public func flatMap<T>(_ transform: @escaping (Value) -> Future<T, Error>) -> Future<T, Error> {
        let promise = Promise<T, Error>()
        self.on(
            success: {
                transform($0).on(
                    success: { promise.fulfill(.success($0)) },
                    failure: { promise.fulfill(.failure($0)) }
                )
            },
            failure: { promise.fulfill(.failure($0)) }
        )
        return Future<T, Error>(scheduler: scheduler, promise: promise)
    }

    public func flatMapError<E>(_ transform: @escaping (Error) -> Future<Value, E>) -> Future<Value, E> {
        let promise = Promise<Value, E>()
        self.on(
            success: {
                promise.fulfill(.success($0))
            },
            failure: {
                transform($0).on(
                    success: { promise.fulfill(.success($0)) },
                    failure: { promise.fulfill(.failure($0)) }
                )
            }
        )
        return Future<Value, E>(scheduler: scheduler, promise: promise)
    }

    public static func just(_ value: Value) -> Future {
        Future { promise in
            promise.fulfill(.success(value))
        }
    }

    public static var empty: Future {
        return Future { _ in }
    }
}

public final class Promise<Value, Error: Swift.Error> {
    private let lock = NSLock()
    private var cachedResult: Result<Value, Error>?
    private var observers: [Future<Value, Error>.Completed] = []

    var result: Result<Value, Error>? {
        lock.lock()
        defer { lock.unlock() }
        return cachedResult
    }

    public init() {}

    /// Fulfills the promise with the result
    public func fulfill(_ result: Result<Value, Error>) {
        lock.lock()
        guard cachedResult == nil else {
            return lock.unlock()
        }

        cachedResult = result
        let observers = self.observers
        self.observers = []
        lock.unlock()

        observers.forEach { $0(result) }
    }

    public func observe(_ observer: @escaping Future<Value, Error>.Completed) {
        lock.lock()
        if let result = cachedResult {
            lock.unlock()
            return observer(result)
        }

        observers.append(observer)
        lock.unlock()
    }
}

public struct Scheduler {
    public typealias Scheduled = (@escaping () -> Void) -> Void
    let schedule: Scheduled

    private init(_ scheduled: @escaping Scheduled) {
        self.schedule = scheduled
    }

    public static func mainQueue() -> Scheduler {
        return Scheduler { Thread.isMainThread ? $0() : DispatchQueue.main.async(execute: $0) }
    }

    public static func async(queue: DispatchQueue) -> Scheduler {
        return Scheduler { queue.async(execute: $0) }
    }

    public static func sync() -> Scheduler {
        return Scheduler { $0() }
    }
}
