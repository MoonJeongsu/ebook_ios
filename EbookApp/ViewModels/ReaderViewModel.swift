import Foundation

struct ReaderUiState {
    var bookId = ""
    var title = ""
    var author = ""
    var content = ""
    var paragraphs: [String] = []
    var initialItemIndex = 0
    var initialScrollOffset = 0
    var isLoading = false
    var errorMessage: String?
}

@MainActor
final class ReaderViewModel: ObservableObject {
    @Published var uiState = ReaderUiState()

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func openBook(_ book: Book) async {
        uiState = ReaderUiState(title: book.title, author: book.author, isLoading: true)

        do {
            try await container.ensureCatalogLoaded()
            let libraryBook = try await container.downloadAndSave(book: book)
            let text = container.readBookText(bookId: book.id) ?? ""
            uiState = ReaderUiState(
                bookId: book.id,
                title: book.title,
                author: book.author,
                content: text,
                paragraphs: splitParagraphs(text),
                initialItemIndex: libraryBook.lastVisibleItemIndex,
                initialScrollOffset: libraryBook.lastVisibleItemScrollOffset,
                isLoading: false
            )
        } catch {
            uiState = ReaderUiState(
                title: book.title,
                author: book.author,
                isLoading: false,
                errorMessage: error.localizedDescription.isEmpty
                    ? "작품을 불러오지 못했습니다."
                    : error.localizedDescription
            )
        }
    }

    func openFromLibrary(bookId: String) async {
        uiState = ReaderUiState(isLoading: true)

        do {
            try await container.ensureCatalogLoaded()
            guard let libraryBook = container.libraryStore.book(for: bookId) else {
                throw ReaderError.bookNotInLibrary
            }
            let text = container.readBookText(bookId: bookId) ?? ""
            uiState = ReaderUiState(
                bookId: bookId,
                title: libraryBook.title,
                author: libraryBook.author,
                content: text,
                paragraphs: splitParagraphs(text),
                initialItemIndex: libraryBook.lastVisibleItemIndex,
                initialScrollOffset: libraryBook.lastVisibleItemScrollOffset,
                isLoading: false
            )
        } catch {
            uiState = ReaderUiState(
                isLoading: false,
                errorMessage: error.localizedDescription.isEmpty
                    ? "작품을 열지 못했습니다."
                    : error.localizedDescription
            )
        }
    }

    func saveProgress(bookId: String, itemIndex: Int, scrollOffset: Int) {
        container.libraryStore.saveProgress(
            bookId: bookId,
            itemIndex: itemIndex,
            scrollOffset: scrollOffset
        )
    }

    private func splitParagraphs(_ text: String) -> [String] {
        text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
            .map(trimEnd)
    }

    private func trimEnd(_ line: String) -> String {
        var result = line
        while let last = result.last, last.isWhitespace {
            result.removeLast()
        }
        return result
    }
}

private enum ReaderError: LocalizedError {
    case bookNotInLibrary

    var errorDescription: String? {
        switch self {
        case .bookNotInLibrary:
            return "서재에 없는 작품입니다."
        }
    }
}
