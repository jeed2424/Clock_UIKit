import Foundation

/// A thread-local implementation, ensuring that the value set/get is the same for a specific thread
@propertyWrapper
public class ThreadLocal<Value> {
    /// The name of the property
    private let name: String

    /// Initiailizer
    public init(_ name: String) {
        self.name = name
    }

    /// The Wrapped value
    public var wrappedValue: Value? {
        get {
            Thread.current.threadDictionary[name] as? Value
        }

        set {
            Thread.current.threadDictionary[name] = newValue
        }
    }
}
