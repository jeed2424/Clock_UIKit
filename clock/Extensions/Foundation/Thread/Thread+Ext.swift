import Foundation

public extension Thread {
    /**
     Execute block, used internally for async/sync functions.

     - parameter block: Process to be executed.
     */
    @objc private func run(block: () -> Void) {
        block()
    }

    /**
     Perform block on current thread asynchronously.

     - parameter block: Process to be executed.
     */
    func async(execute: @escaping () -> Void) {
        guard Thread.current != self else { return execute() }
        perform(#selector(run(block:)), on: self, with: execute, waitUntilDone: false)
    }

    /**
     Perform block on current thread synchronously.

     - parameter block: Process to be executed.
     */
    func sync(execute: @escaping () -> Void) {
        guard Thread.current != self else { return execute() }
        perform(#selector(run(block:)), on: self, with: execute, waitUntilDone: true)
    }
}
