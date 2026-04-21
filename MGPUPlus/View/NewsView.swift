import SwiftUI

struct NewsView: View {
    @State private var items: [NewsItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let newsService = NewsService()

    var body: some View {
        NavigationStack {
            content
                .background(Color.appDarkGroupedBackground)
                .navigationTitle("tab.news")
                .task {
                    guard items.isEmpty else { return }
                    await loadNews()
                }
        }
        .background(Color.appDarkGroupedBackground)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading && items.isEmpty {
            ProgressView("news.loading")
                .tint(.mcuRed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage, items.isEmpty {
            ContentUnavailableView {
                Label("news.error.title", systemImage: "newspaper")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("news.retry") {
                    _Concurrency.Task {
                        await loadNews()
                    }
                }
            }
        } else if items.isEmpty {
            ContentUnavailableView("news.empty", systemImage: "newspaper")
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(items) { item in
                        NewsCardView(item: item)
                    }
                }
                .padding(16)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                await loadNews()
            }
        }
    }

    @MainActor
    private func loadNews() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await newsService.fetchNews()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct NewsCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    let item: NewsItem

    var body: some View {
        NavigationLink {
            NewsDetailView(item: item)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                AsyncImage(url: item.imageURL) { phase in
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
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 8) {
                    if !metaText.isEmpty {
                        Text(metaText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.mcuRed)
                    }

                    Text(item.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color(uiColor: .label))
                        .multilineTextAlignment(.leading)

                    Text(item.summary)
                        .font(.subheadline)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(14)
            .background(cardBackgroundColor, in: RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
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

    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color.appDarkCardBackground : .mcuLightGrey.opacity(0.25)
    }

    private var metaText: String {
        [item.sourceTitle, item.dateText]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}

#Preview {
    NewsView()
}
