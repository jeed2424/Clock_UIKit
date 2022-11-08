import Foundation

/// The protocol for all synchronized value
public protocol SynchronizedValue {

    /// The associated type
    associatedtype ValueType

    /// A simple return value
    var value: ValueType { get }

    /// A mutating function for the value
    mutating func value<T>(execute task: (inout ValueType) throws -> T) rethrows -> T

}
