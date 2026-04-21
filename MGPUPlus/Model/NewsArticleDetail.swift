import Foundation

struct NewsArticleDetail: Hashable {
    let title: String
    let sourceTitle: String
    let dateText: String
    let imageURL: URL?
    let bodyText: String
    let articleURL: URL
}
