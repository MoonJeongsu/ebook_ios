import Foundation

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var authors: [Author] = []
    @Published var searchQuery = ""
    @Published var searchResults: [Book] = []

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        Task { await refresh() }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            try await container.ensureCatalogLoaded()
            authors = container.getAuthors()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription.isEmpty
                ? "목록을 불러오지 못했습니다."
                : error.localizedDescription
        }
    }

    func updateSearchQuery(_ query: String) {
        searchQuery = query
        searchResults = query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? []
            : container.searchBooks(query: query)
    }

    func author(for authorId: String) -> Author? {
        authors.first { $0.id == authorId }
    }

    func books(for authorId: String) -> [Book] {
        guard let author = author(for: authorId) else { return [] }
        return container.getBooks(for: author)
    }
}
