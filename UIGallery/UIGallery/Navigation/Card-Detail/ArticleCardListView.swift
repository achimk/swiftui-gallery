import SwiftUI

struct ArticleCardListView: View {
    let articles: [ArticleModel]
    
    var body: some View {
        ScrollView {
            Spacer(minLength: 40)
            
            LazyVStack(spacing: 40) {
                ForEach(articles) { article in
                    ArticleCardView(article: article)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct ArticleCardView: View {
    let article: ArticleModel
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(article.category.toColor())
                .frame(height: 260)
            
            ArticleExcerptView(article: article)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .background(.white)
        .compositingGroup()
        .cornerRadius(15)
        .shadow(radius: 15)
    }
}

struct ArticleExcerptView: View {
    let article: ArticleModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ArticleCategoryView(
                    category: article.category.toTitle(),
                    color: article.category.toColor())
                
                Spacer()
                
                Text(ArticleModel.dayFormatter.string(from: article.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(article.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .padding(.bottom, 4)
            
            Text(article.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
    }
}

struct ArticleCategoryView: View {
    let category: String
    let color: Color
    
    var body: some View {
        Group {
            Text(category)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
        }
        .background(color, in: Capsule())
    }
}

struct ArticleTagsView: View {
    let tags: [String]
    
    var body: some View {
        HStack {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
            }
        }
    }
}

struct ArticleCardListView_Previews: PreviewProvider {
    static let article = ArticleModel.generate()
    static let articles = ArticleModel.generate(count: 10)
    
    static var previews: some View {
        
        ArticleCardView(article: article)
            .previewDisplayName("Card")
        
        ArticleCardListView(articles: articles)
            .previewDisplayName("Card list")
    }
}
