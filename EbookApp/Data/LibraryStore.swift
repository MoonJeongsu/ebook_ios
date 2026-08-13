import Combine
import Foundation

@MainActor
final class LibraryStore: ObservableObject {
    @Published private(set) var books: [LibraryBook] = []

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        fileURL = base.appendingPathComponent("library_books.json")
        books = loadBooks()
    }

    func book(for bookId: String) -> LibraryBook? {
        books.first { $0.bookId == bookId }
    }

    func upsert(_ book: LibraryBook) {
        if let index = books.firstIndex(where: { $0.bookId == book.bookId }) {
            books[index] = book
        } else {
            books.append(book)
        }
        books.sort { $0.lastReadAt > $1.lastReadAt }
        persist()
    }

    func saveProgress(bookId: String, itemIndex: Int, scrollOffset: Int) {
        guard var existing = book(for: bookId) else { return }
        existing.lastVisibleItemIndex = itemIndex
        existing.lastVisibleItemScrollOffset = scrollOffset
        existing.lastReadAt = Date().timeIntervalSince1970
        upsert(existing)
    }

    private func loadBooks() -> [LibraryBook] {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let decoded = try? decoder.decode([LibraryBook].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.lastReadAt > $1.lastReadAt }
    }

    private func persist() {
        guard let data = try? encoder.encode(books) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
