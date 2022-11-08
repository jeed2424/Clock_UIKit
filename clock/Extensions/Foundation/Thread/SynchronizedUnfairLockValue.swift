import Foundation
import os

///
/// An implementation of a synchronized value by a `os_unfair_lock_t`
///
/// For a concurrent read-write locking, use `SynchronizedBarrierValue`. CPU-usage is bound by GCD, will not exceed 100%
/// For a slightly faster write locking, use `SynchronizedSemaphoreValue`. CPU-usage is bound by GCD, will not exceed 100%
/// For crazy fast read-write, `SynchronizedUnfairLockValue` or `SynchronizedNSLockValue`. Beware, CPU-usage is unbounded, and will degrade battery life
/// For unix-style mutex, use `SynchronizedPThreadMutex`. Beware, CPU-usage is unbounded, and will degrade battery life
/// For unix-style read-write lock, use `SynchronizedPThreadReadWriteLock`. Beware, CPU-usage is unbounded, and will degrade battery life
///
public struct SynchronizedUnfairLockValue<V>: SynchronizedValue {

    private let unfairLock: os_unfair_lock_t
    private var _value: V

    public init(_ value: V) {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
        _value = value
    }

    /// A simple return value
    public var value: V {
        os_unfair_lock_lock(unfairLock)
        defer {
            os_unfair_lock_unlock(unfairLock)
        }
        return _value
    }

    /// A mutating function for the value
    public mutating func value<T>(execute task: (inout V) throws -> T) rethrows -> T {
        os_unfair_lock_lock(unfairLock)
        do {
            defer {
                os_unfair_lock_unlock(unfairLock)
            }
            return try task(&_value)
        } catch {
            os_unfair_lock_unlock(unfairLock)
            throw error
        }
    }
}
