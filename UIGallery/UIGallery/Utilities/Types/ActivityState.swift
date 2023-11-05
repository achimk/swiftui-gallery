import Foundation

enum ActivityState: Int, Identifiable, Equatable, CaseIterable {
    case initial
    case loading
    case success
    case failure
    var id: Int { rawValue }
}
