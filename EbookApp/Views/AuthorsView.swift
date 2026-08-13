import SwiftUI

struct AuthorsView: View {
    @ObservedObject var viewModel: CatalogViewModel
    @ObservedObject var container: AppContainer

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    Task { await viewModel.refresh() }
                }
            } else if viewModel.authors.isEmpty {
                EmptyStateView(message: "등록된 작가가 없습니다.")
            } else {
                List(viewModel.authors) { author in
                    NavigationLink {
                        AuthorBooksView(
                            authorName: author.name,
                            books: viewModel.books(for: author.id),
                            container: container
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(author.name)
                                .font(.headline)
                                .foregroundStyle(AppTheme.onSurface)
                            Text("\(author.bookCount)편")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.onSurface.opacity(0.7))
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("작가")
        .background(AppTheme.background)
    }
}
