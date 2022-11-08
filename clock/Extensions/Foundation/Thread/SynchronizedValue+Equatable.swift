import Foundation

/// Add methods for equatable
public extension SynchronizedValue where ValueType: Equatable {

    /// Change the value only if the current value matches the preconditions
    ///
    /// - parameter expected: The preconditions
    /// - parameter newValue: The new value to set if the condition is met
    /// - returns: The value
    mutating func compareAndSet(expected: ValueType, newValue: ValueType) -> ValueType {
        value {
            if $0 == expected {
                $0 = newValue
            }
            return $0
        }
    }

    /// Set value, return the previous value
    ///
    /// - parameter newValue: The value to set
    /// - returns: The previous value
    mutating func getAndSet(newValue: ValueType) -> ValueType {
        value {
            let value = $0
            $0 = newValue
            return value
        }
    }
}
