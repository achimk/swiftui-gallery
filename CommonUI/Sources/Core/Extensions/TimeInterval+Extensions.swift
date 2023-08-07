import Foundation

public extension TimeInterval {
    static let millisecond: TimeInterval = second / 1000.0
    static let second: TimeInterval = 1.0
    static let minute: TimeInterval = 60.0 * second
    static let hour: TimeInterval = 60.0 * minute
    static let day: TimeInterval = 24.0 * hour

    static func milliseconds(_ factor: Int) -> TimeInterval {
        millisecond * Double(factor)
    }

    static func seconds(_ factor: Int) -> TimeInterval {
        second * Double(factor)
    }

    static func minutes(_ factor: Int) -> TimeInterval {
        minute * Double(factor)
    }

    static func hours(_ factor: Int) -> TimeInterval {
        hour * Double(factor)
    }

    static func days(_ factor: Int) -> TimeInterval {
        day * Double(factor)
    }
}
