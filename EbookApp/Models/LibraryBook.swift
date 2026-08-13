import Foundation

struct LibraryBook: Identifiable, Codable, Hashable {
    var id: String { bookId }

    let bookId: String
    let title: String
    let author: String
    let storagePath: String
    let localFileName: String
    var lastVisibleItemIndex: Int
    var lastVisibleItemScrollOffset: Int
    let downloadedAt: TimeInterval
    var lastReadAt: TimeInterval
}
