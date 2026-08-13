import SwiftUI

struct LibraryView: View {
    @ObservedObject var libraryStore: LibraryStore
    @ObservedObject var container: AppContainer

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter
    }()

    var body: some View {
        Group {
            if libraryStore.books.isEmpty {
                EmptyStateView(message: "다운로드한 작품이 없습니다.\n작가 또는 검색에서 작품을 열어보세요.")
            } else {
                List(libraryStore.books) { book in
                    NavigationLink {
                        ReaderContainerView(bookId: book.bookId, container: container)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.onSurface)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.onSurface.opacity(0.85))
                            Text("마지막 읽은 시간: \(Self.dateFormatter.string(from: Date(timeIntervalSince1970: book.lastReadAt)))")
                                .font(.caption)
                                .foregroundStyle(AppTheme.onSurface.opacity(0.65))
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("내 서재")
        .background(AppTheme.background)
    }
}
