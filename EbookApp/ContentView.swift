import SwiftUI

struct ContentView: View {
    @ObservedObject var container: AppContainer
    @ObservedObject var libraryStore: LibraryStore

    @StateObject private var catalogViewModel: CatalogViewModel

    init(container: AppContainer, libraryStore: LibraryStore) {
        self.container = container
        self.libraryStore = libraryStore
        _catalogViewModel = StateObject(wrappedValue: CatalogViewModel(container: container))
    }

    var body: some View {
        TabView {
            NavigationStack {
                AuthorsView(viewModel: catalogViewModel, container: container)
            }
            .tabItem {
                Label("작가", systemImage: "person")
            }

            NavigationStack {
                SearchView(viewModel: catalogViewModel, container: container)
            }
            .tabItem {
                Label("검색", systemImage: "magnifyingglass")
            }

            NavigationStack {
                LibraryView(libraryStore: libraryStore, container: container)
            }
            .tabItem {
                Label("내 서재", systemImage: "book")
            }
        }
        .background(AppTheme.background)
    }
}
