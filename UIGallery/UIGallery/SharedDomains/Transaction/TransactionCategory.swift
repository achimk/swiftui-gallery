import Foundation
import SwiftUI

enum TransactionCategory: Int, Identifiable, Equatable, CaseIterable {
    case income
    case savings
    case eat
    case lifeStyle
    case transport
    case other
    var id: Int { rawValue }
}

extension TransactionCategory {
    var color: Color {
        switch self {
        case .income: return .cyan
        case .savings: return .pink
        case .eat: return .purple
        case .lifeStyle: return .mint
        case .transport: return .indigo
        case .other: return .orange
        }
    }

    var title: String {
        switch self {
        case .income: return "Income"
        case .savings: return "Savings"
        case .eat: return "Eat"
        case .lifeStyle: return "Life style"
        case .transport: return "Transport"
        case .other: return "Other"
        }
    }
}
