import SwiftUI

struct ReaderContainerView: View {
    let bookId: String
    @ObservedObject var container: AppContainer

    @StateObject private var viewModel: ReaderViewModel
    @Environment(\.dismiss) private var dismiss

    init(bookId: String, container: AppContainer) {
        self.bookId = bookId
        self.container = container
        _viewModel = StateObject(wrappedValue: ReaderViewModel(container: container))
    }

    var body: some View {
        ReaderView(viewModel: viewModel, bookId: bookId) {
            dismiss()
        }
        .task(id: bookId) {
            if container.libraryStore.book(for: bookId) != nil,
               container.localBookFileExists(bookId: bookId) {
                await viewModel.openFromLibrary(bookId: bookId)
                return
            }

            do {
                try await container.ensureCatalogLoaded()
                if let book = container.getBook(byId: bookId) {
                    await viewModel.openBook(book)
                } else {
                    await viewModel.openFromLibrary(bookId: bookId)
                }
            } catch {
                await viewModel.openFromLibrary(bookId: bookId)
            }
        }
    }
}

struct BookReaderContainerView: View {
    let book: Book
    @ObservedObject var container: AppContainer

    @StateObject private var viewModel: ReaderViewModel
    @Environment(\.dismiss) private var dismiss

    init(book: Book, container: AppContainer) {
        self.book = book
        self.container = container
        _viewModel = StateObject(wrappedValue: ReaderViewModel(container: container))
    }

    var body: some View {
        ReaderView(viewModel: viewModel, bookId: book.id) {
            dismiss()
        }
        .task(id: book.id) {
            await viewModel.openBook(book)
        }
    }
}
