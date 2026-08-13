import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: CatalogViewModel
    @ObservedObject var container: AppContainer

    var body: some View {
        VStack(spacing: 0) {
            TextField("작가명 또는 작품명", text: Binding(
                get: { viewModel.searchQuery },
                set: { viewModel.updateSearchQuery($0) }
            ))
            .textFieldStyle(.roundedBorder)
            .padding()

            if viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                EmptyStateView(message: "검색어를 입력하세요.")
            } else if viewModel.searchResults.isEmpty {
                EmptyStateView(message: "검색 결과가 없습니다.")
            } else {
                List(viewModel.searchResults) { book in
                    NavigationLink {
                        BookReaderContainerView(book: book, container: container)
                    } label: {
                        BookRowContent(book: book)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("검색")
        .background(AppTheme.background)
    }
}
