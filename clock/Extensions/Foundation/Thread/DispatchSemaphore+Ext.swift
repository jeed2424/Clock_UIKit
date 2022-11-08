import Foundation

public extension DispatchSemaphore {
    /// Utility method that provices an easy way for locking a resource
    func lock<T>(execute task: () throws -> T) rethrows -> T {
        wait()
        defer { signal() }
        return try task()
    }
}
