import Foundation
import SwiftUI

enum ArticleCategory: String, CaseIterable {
    case news
    case review
    case commentary
    case advertisement
    case editorial
    case research
    case analysis
    case caseStudy
}

extension ArticleCategory {
    func toColor() -> Color {
        switch self {
        case .news: return .mint
        case .review: return .pink
        case .commentary: return .orange
        case .advertisement: return .teal
        case .editorial: return .red
        case .research: return .purple
        case .analysis: return .cyan
        case .caseStudy: return .indigo
        }
    }
    
    func toTitle() -> String {
        switch self {
        case .news: return "News"
        case .review: return "Review"
        case .commentary: return "Commentary"
        case .advertisement: return "Advertisement"
        case .editorial: return "Editorial"
        case .research: return "Research"
        case .analysis: return "Analysis"
        case .caseStudy: return "Case study"
        }
    }
}

struct ArticleRate {
    static let minValue: Int = 0
    static let maxValue: Int = 5
    
    static var range: ClosedRange<Int> = {
        minValue...maxValue
    }()
    
    var value: Int
    
    init(_ value: Int) {
        self.value = min(max(value, Self.minValue), Self.maxValue)
    }
}

struct ArticleModel: Identifiable {
    var id = UUID()
    var title: String
    var body: String
    var author: String
    var date: Date
    var tags: [String]
    var category: ArticleCategory
    var rate: ArticleRate
}

extension ArticleModel {
    
    static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM YYYY"
        return formatter
    }()
    
    static func generate(count: Int) -> [ArticleModel] {
        (1...count).map { _ in generate() }
    }
    
    static func generate() -> ArticleModel {
        let rateValue = ArticleRate.range.randomElement() ?? ArticleRate.minValue
        let category = ArticleCategory.allCases.randomElement() ?? ArticleCategory.news
        let tags = generateTags(count: (1...4).randomElement() ?? 1)
        return ArticleModel(
            title: Self.title,
            body: Self.body,
            author: "Lorem Ipsum",
            date: Date(),
            tags: tags,
            category: category,
            rate: .init(rateValue))
    }
    
    static func generateTags(count: Int) -> [String] {
        return (1...count).map { _ in
            Self.tags.randomElement() ?? "none"
        }
    }
    
    static let tags: [String] = ["metrics", "reporting", "work", "creativity", "writing", "story", "journalism", "history", "travel", "tech", "family", "science", "fiction", "movies", "space", "photography", "art", "business", "inspiration", "marketing", "self improvement", "music"]
    
    static let title: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    
    static let body: String = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis pellentesque dolor quis neque mollis, euismod hendrerit metus iaculis. Aliquam eu nisl mi. Etiam ornare urna metus, luctus feugiat quam hendrerit sed. Etiam id nisi at tellus varius auctor. Nunc mollis tempus urna quis sagittis. Vestibulum vitae molestie mi. Vestibulum vitae enim id leo accumsan viverra quis et risus. Aenean aliquam aliquet ligula sed tempor. Nunc nec diam nunc. In hac habitasse platea dictumst. Praesent faucibus felis vel mollis fringilla. Cras libero risus, tempus at pretium vitae, ornare id mi. Phasellus nec eros sit amet libero finibus viverra. Nunc neque arcu, dignissim scelerisque cursus vitae, ultrices non est. Cras convallis dolor nibh, vulputate vestibulum risus ullamcorper at.

    Curabitur nec tortor lacus. Integer porttitor tincidunt turpis, vitae hendrerit dui dignissim quis. Mauris nec fermentum nibh. Nam tempus dui et libero viverra egestas. Nulla in lorem imperdiet, sodales felis et, blandit dui. Nunc semper libero augue, ut porta felis imperdiet nec. Integer lacus quam, tincidunt nec nunc in, volutpat finibus erat. Maecenas metus elit, laoreet nec efficitur sit amet, luctus in nisi. Mauris ultrices justo dui, nec suscipit lacus tincidunt ut. Nullam vel fringilla erat. Donec metus dolor, pellentesque ut ligula a, pharetra placerat justo. Vivamus augue arcu, lobortis in congue quis, tristique sed libero. Aenean vulputate ex vitae faucibus egestas. Curabitur egestas felis sit amet quam accumsan, quis maximus lectus volutpat. Duis facilisis in velit id varius.

    Nulla vitae risus a nibh venenatis consequat. Etiam pulvinar metus in volutpat facilisis. Nulla lorem leo, hendrerit sit amet cursus eu, condimentum eu neque. Donec ultrices aliquam orci, in fermentum nibh dapibus eget. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Etiam id pulvinar neque. Praesent ac molestie mi, sit amet convallis sapien. In hac habitasse platea dictumst. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vulputate laoreet arcu quis pharetra. Donec tincidunt malesuada nulla, ac lobortis velit. Sed tellus ipsum, tristique quis eleifend vel, rhoncus in massa. Ut pulvinar pharetra leo, at pretium diam facilisis imperdiet.

    Aenean nec ex in nulla cursus tempor. Mauris egestas cursus mauris at dapibus. Quisque mauris lectus, blandit id facilisis sed, gravida in ante. Suspendisse id egestas elit. Nunc malesuada, dui sed finibus mollis, augue mauris commodo nibh, ac ornare tortor sapien fringilla mi. Proin lacinia, sapien in congue interdum, massa elit ornare turpis, nec consectetur nisl metus vitae augue. Nunc convallis purus justo, pulvinar suscipit sem accumsan scelerisque. Phasellus consectetur, justo ut posuere ullamcorper, magna justo iaculis felis, et molestie purus ipsum id justo. Nullam scelerisque feugiat malesuada. Sed massa dui, tempus at ullamcorper a, aliquet vitae nulla. Vestibulum ut turpis et ipsum consequat imperdiet in vel dolor. Quisque consectetur eros et diam condimentum molestie. Morbi libero tortor, pharetra ac laoreet sit amet, facilisis et nisi. Pellentesque ante nunc, sodales vitae risus sit amet, tempor dapibus sapien.

    Sed nec rhoncus magna. Nullam varius porta lobortis. Maecenas eget nisi at risus luctus ullamcorper. Duis at arcu tincidunt, ultricies quam eu, lobortis augue. Cras ut leo neque. Vestibulum at lectus leo. Pellentesque vel arcu vitae quam cursus ornare. Mauris iaculis felis vitae ante commodo, non consectetur ipsum rutrum. Donec lobortis dolor a arcu tincidunt, non maximus risus pharetra. Etiam nec nisl vitae diam commodo auctor at ac dolor. Nullam pulvinar nibh in urna vestibulum suscipit. Praesent sed accumsan ipsum. In varius massa sit amet quam viverra tempus. Nunc vitae aliquet quam.
    """
}
