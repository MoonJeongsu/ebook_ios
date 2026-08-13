import Foundation

@MainActor
final class AppContainer: ObservableObject {
    private let firestoreRepository = FirestoreRepository()
    private let storageRepository = StorageRepository()
    let libraryStore: LibraryStore

    private var cachedAuthors: [Author] = []
    private var cachedBooks: [Book] = []

    init(libraryStore: LibraryStore) {
        self.libraryStore = libraryStore
    }

    func ensureCatalogLoaded() async throws {
        if cachedBooks.isEmpty {
            cachedBooks = try await firestoreRepository.fetchBooks()
        }
        if cachedAuthors.isEmpty {
            cachedAuthors = try await firestoreRepository.fetchAuthors()
        }
    }

    func getAuthors() -> [Author] {
        cachedAuthors
    }

    func getBook(byId bookId: String) -> Book? {
        cachedBooks.first { $0.id == bookId }
    }

    func getBooks(for author: Author) -> [Book] {
        let shortName = author.name.components(separatedBy: "(").first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? author.name
        let normalizedShortName = QueryNormalizer.normalize(shortName)

        return cachedBooks.filter { book in
            book.author == shortName ||
                book.author == author.name ||
                author.name.contains(book.author) ||
                book.searchAuthor == normalizedShortName
        }
        .sorted { $0.title < $1.title }
    }

    func searchBooks(query: String) -> [Book] {
        let normalized = QueryNormalizer.normalize(query)
        guard !normalized.isBlank else { return [] }

        return cachedBooks.filter { book in
            book.title.localizedCaseInsensitiveContains(query) ||
                book.author.localizedCaseInsensitiveContains(query) ||
                book.searchTitle.contains(normalized) ||
                book.searchAuthor.contains(normalized)
        }
        .sorted {
            if $0.author == $1.author {
                return $0.title < $1.title
            }
            return $0.author < $1.author
        }
    }

    func downloadAndSave(book: Book) async throws -> LibraryBook {
        let localURL = try await storageRepository.downloadBook(storagePath: book.storagePath, bookId: book.id)
        let now = Date().timeIntervalSince1970
        let existing = libraryStore.book(for: book.id)

        let entity = LibraryBook(
            bookId: book.id,
            title: book.title,
            author: book.author,
            storagePath: book.storagePath,
            localFileName: localURL.lastPathComponent,
            lastVisibleItemIndex: existing?.lastVisibleItemIndex ?? 0,
            lastVisibleItemScrollOffset: existing?.lastVisibleItemScrollOffset ?? 0,
            downloadedAt: existing?.downloadedAt ?? now,
            lastReadAt: now
        )
        libraryStore.upsert(entity)
        return entity
    }

    func readBookText(bookId: String) -> String? {
        storageRepository.readLocalText(bookId: bookId)
    }

    func localBookFileExists(bookId: String) -> Bool {
        storageRepository.localFileURL(for: bookId) != nil
    }
}

private extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
