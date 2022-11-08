import Foundation

/// Add methods for binary floating points
public extension SynchronizedValue where ValueType: BinaryFloatingPoint {

    /// Add value only if the current value matches the preconditions
    ///
    /// - parameter newValue: The value to add
    /// - returns: The value
    mutating func addAndGet(newValue: ValueType) -> ValueType {
        value {
            $0 = $0 + newValue
            return $0
        }
    }

    /// Substract value only if the current value matches the preconditions
    ///
    /// - parameter newValue: The value to add
    /// - returns: The value
    mutating func substractAndGet(newValue: ValueType) -> ValueType {
        value {
            $0 = $0 - newValue
            return $0
        }
    }

    /// Increment value, return the previous value
    ///
    /// - returns: The previous value
    mutating func getAndIncrement() -> ValueType {
        value {
            let value = $0
            $0 = $0 + 1
            return value
        }
    }

    /// Decrement value, return the previous value
    ///
    /// - returns: The previous value
    mutating func getAndDecrement() -> ValueType {
        value {
            let value = $0
            $0 = $0 - 1
            return value
        }
    }

    /// Increment value, return the new value
    ///
    /// - returns: The new value
    mutating func incrementAndGet() -> ValueType {
        value {
            $0 = $0 + 1
            return $0
        }
    }

    /// Decrement value, return the new value
    ///
    /// - returns: The new value
    mutating func decrementAndGet() -> ValueType {
        value {
            $0 = $0 - 1
            return $0
        }
    }
}
