import SwiftUI

struct NewsDetailView: View {
    let item: NewsItem

    @State private var detail: NewsArticleDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let newsService = NewsService()

    var body: some View {
        Group {
            if isLoading && detail == nil {
                ProgressView("news.detail.loading")
                    .tint(.mcuRed)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        AsyncImage(url: detail.imageURL) { phase in
                            switch phase {
                            case .empty:
                                placeholder
                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 22))

                        VStack(alignment: .leading, spacing: 10) {
                            if !metaText(for: detail).isEmpty {
                                Text(metaText(for: detail))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.mcuRed)
                            }

                            Text(detail.title)
                                .font(.title2.bold())
                                .foregroundStyle(Color(uiColor: .label))

                            Text(detail.bodyText)
                                .font(.body)
                                .foregroundStyle(Color(uiColor: .label))
                                .lineSpacing(5)
                        }

                        Link(destination: detail.articleURL) {
                            Label("news.detail.open_source", systemImage: "safari")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.mcuRed, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await loadDetail()
                }
            } else if let errorMessage {
                ContentUnavailableView {
                    Label("news.error.title", systemImage: "doc.text.image")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("news.retry") {
                        _Concurrency.Task {
                            await loadDetail()
                        }
                    }
                }
            } else {
                ContentUnavailableView("news.empty", systemImage: "doc.text.image")
            }
        }
        .background(Color.appDarkGroupedBackground)
        .navigationTitle("news.detail.title")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard detail == nil else { return }
            await loadDetail()
        }
    }

    @MainActor
    private func loadDetail() async {
        isLoading = true
        defer { isLoading = false }

        do {
            detail = try await newsService.fetchNewsDetail(for: item)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func metaText(for detail: NewsArticleDetail) -> String {
        [detail.sourceTitle, detail.dateText]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [.mcuRed.opacity(0.9), .mcuGrey.opacity(0.55), .mcuLightGrey.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "photo")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
    }
}

#Preview {
    NavigationStack {
        NewsDetailView(
            item: NewsItem(
                title: "Пример новости",
                summary: "Краткое описание",
                dateText: "21 апреля 2026 г.",
                sourceTitle: "МГПУ",
                imageURL: nil,
                articleURL: URL(string: "https://www.mgpu.ru/news/")!
            )
        )
    }
}
