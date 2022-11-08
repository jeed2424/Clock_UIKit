import Foundation

/// A synchronized value using a semaphore
///
/// For a concurrent read-write locking, use `SynchronizedBarrierValue`. CPU-usage is bound by GCD, will not exceed 100%
/// For a slightly faster write locking, use `SynchronizedSemaphoreValue`. CPU-usage is bound by GCD, will not exceed 100%
/// For crazy fast read-write, `SynchronizedUnfairLockValue` or `SynchronizedNSLockValue`. Beware, CPU-usage is unbounded, and will degrade battery life
/// For unix-style mutex, use `SynchronizedPThreadMutex`. Beware, CPU-usage is unbounded, and will degrade battery life
/// For unix-style read-write lock, use `SynchronizedPThreadReadWriteLock`. Beware, CPU-usage is unbounded, and will degrade battery life
///
public struct SynchronizedSemaphoreValue<V>: SynchronizedValue {

    private let mutex = DispatchSemaphore(value: 1)
    private var _value: V

    public init(_ value: V) {
        _value = value
    }

    /// A simple return value
    public var value: V {
        mutex.lock { _value }
    }

    /// A mutating function for the value
    public mutating func value<T>(execute task: (inout V) throws -> T) rethrows -> T {
        mutex.wait()
        do {
            defer {
                mutex.signal()
            }
            return try task(&_value)
        } catch {
            mutex.signal()
            throw error
        }
    }
}
