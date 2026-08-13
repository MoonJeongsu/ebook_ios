import FirebaseCore
import SwiftUI

@main
struct EbookAppApp: App {
    @StateObject private var libraryStore = LibraryStore()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var container: AppContainer

    init() {
        FirebaseApp.configure()
        let store = LibraryStore()
        _libraryStore = StateObject(wrappedValue: store)
        _container = StateObject(wrappedValue: AppContainer(libraryStore: store))
        _networkMonitor = StateObject(wrappedValue: NetworkMonitor())
    }

    var body: some Scene {
        WindowGroup {
            NetworkGate(networkMonitor: networkMonitor) {
                ContentView(container: container, libraryStore: libraryStore)
            }
            .tint(AppTheme.primary)
        }
    }
}
