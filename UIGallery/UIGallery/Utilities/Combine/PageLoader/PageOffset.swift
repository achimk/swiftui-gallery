import Foundation

enum PageOffset: Equatable {
    case completed
    case available(offset: UInt)
    
    static let initial = PageOffset.available(offset: 0)

    var isCompleted: Bool {
        switch self {
        case .completed: return true
        case .available: return false
        }
    }
}
