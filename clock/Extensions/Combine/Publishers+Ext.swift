import Combine
import Foundation

/// Extension for publishers, hadding easier integration
public extension Publishers {

    /// Return a timer publisher
    static func timer(_ interval: TimeInterval, runLoop: RunLoop = RunLoop.current) -> Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: interval, on: runLoop, in: .default).autoconnect()
    }
}

// MARK: - Notifications
public extension Publishers {

    /// Return a notification publisher
    static func notification(_ name: Notification.Name, object: AnyObject? = nil) -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: name, object: object)
    }
}
