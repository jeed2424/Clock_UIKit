import Foundation

/// A `pthread_mutex_t` implementation of the synchronized value.
///
/// For a concurrent read-write locking, use `SynchronizedBarrierValue`. CPU-usage is bound by GCD, will not exceed 100%
/// For a slightly faster write locking, use `SynchronizedSemaphoreValue`. CPU-usage is bound by GCD, will not exceed 100%
/// For crazy fast read-write, `SynchronizedUnfairLockValue` or `SynchronizedNSLockValue`. Beware, CPU-usage is unbounded, and will degrade battery life
/// For unix-style mutex, use `SynchronizedPThreadMutex`. Beware, CPU-usage is unbounded, and will degrade battery life
/// For unix-style read-write lock, use `SynchronizedPThreadReadWriteLock`. Beware, CPU-usage is unbounded, and will degrade battery life
///
public class SynchronizedPThreadMutex<V>: SynchronizedValue {

    private var mutex = pthread_mutex_t()
    private var _value: V

    public init(_ value: V) {
        pthread_mutex_init(&mutex, nil)
        _value = value
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    /// A simple return value
    public var value: V {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        return _value
    }

    /// A mutating function for the value
    public func value<T>(execute task: (inout V) throws -> T) rethrows -> T {
        pthread_mutex_lock(&mutex)
        do {
            defer {
                pthread_mutex_unlock(&mutex)
            }
            return try task(&_value)
        } catch {
            pthread_mutex_unlock(&mutex)
            throw error
        }
    }
}
