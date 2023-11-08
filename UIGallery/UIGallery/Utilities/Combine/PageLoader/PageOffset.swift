import Foundation

enum PageOffset: Equatable {
    case available(offset: UInt)
    case completed

    var isAvailable: Bool {
        switch self {
        case .available: return true
        case .completed: return false
        }
    }

    var isCompleted: Bool {
        switch self {
        case .available: return false
        case .completed: return true
        }
    }

    static let initial = PageOffset.available(offset: 0)
}
