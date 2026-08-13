import Foundation

struct Book: Identifiable, Hashable {
    let id: String
    let author: String
    let title: String
    let filename: String
    let storagePath: String
    let source: String
    let searchTitle: String
    let searchAuthor: String
}
