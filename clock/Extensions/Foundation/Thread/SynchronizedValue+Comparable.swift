import Foundation

/// Add methods for equatable
public extension SynchronizedValue where ValueType: Comparable {

    /// Change the value only if the current value greater than specified expectation
    ///
    /// - parameter expected: The preconditions
    /// - parameter newValue: The new value to set if the condition is met
    /// - returns: The value
    mutating func compareGreaterThanAndSet(expected: ValueType, newValue: ValueType) -> ValueType {
        value {
            if $0 > expected {
                $0 = newValue
            }
            return $0
        }
    }

    /// Change the value only if the current value greater or equal than specified expectation
    ///
    /// - parameter expected: The preconditions
    /// - parameter newValue: The new value to set if the condition is met
    /// - returns: The value
    mutating func compareGreaterOrEqualThanAndSet(expected: ValueType, newValue: ValueType) -> ValueType {
        value {
            if $0 >= expected {
                $0 = newValue
            }
            return $0
        }
    }

    /// Change the value only if the current value lower than specified expectation
    ///
    /// - parameter expected: The preconditions
    /// - parameter newValue: The new value to set if the condition is met
    /// - returns: The value
    mutating func compareLowerThanAndSet(expected: ValueType, newValue: ValueType) -> ValueType {
        value {
            if $0 < expected {
                $0 = newValue
            }
            return $0
        }
    }

    /// Change the value only if the current value lower or equal than specified expectation
    ///
    /// - parameter expected: The preconditions
    /// - parameter newValue: The new value to set if the condition is met
    /// - returns: The value
    mutating func compareLowerOrEqualThanAndSet(expected: ValueType, newValue: ValueType) -> ValueType {
        value {
            if $0 <= expected {
                $0 = newValue
            }
            return $0
        }
    }
}
