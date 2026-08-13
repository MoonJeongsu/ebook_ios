import SwiftUI

struct AuthorBooksView: View {
    let authorName: String
    let books: [Book]
    @ObservedObject var container: AppContainer

    var body: some View {
        Group {
            if books.isEmpty {
                EmptyStateView(message: "작품이 없습니다.")
            } else {
                List(books) { book in
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
        .navigationTitle(authorName)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.background)
    }
}
