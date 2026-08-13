import FirebaseStorage
import Foundation

struct StorageRepository {
    private let booksDirectory: URL
    private let storage: Storage

    init(storage: Storage = Storage.storage()) {
        self.storage = storage
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        booksDirectory = base.appendingPathComponent("books", isDirectory: true)
        try? FileManager.default.createDirectory(at: booksDirectory, withIntermediateDirectories: true)
    }

    func downloadBook(storagePath: String, bookId: String) async throws -> URL {
        let localURL = booksDirectory.appendingPathComponent("\(bookId).txt")
        if FileManager.default.fileExists(atPath: localURL.path),
           let attributes = try? FileManager.default.attributesOfItem(atPath: localURL.path),
           let fileSize = attributes[.size] as? NSNumber,
           fileSize.intValue > 0 {
            return localURL
        }

        let reference = storage.reference(withPath: storagePath)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.write(toFile: localURL) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        return localURL
    }

    func localFileURL(for bookId: String) -> URL? {
        let localURL = booksDirectory.appendingPathComponent("\(bookId).txt")
        guard FileManager.default.fileExists(atPath: localURL.path),
              let attributes = try? FileManager.default.attributesOfItem(atPath: localURL.path),
              let fileSize = attributes[.size] as? NSNumber,
              fileSize.intValue > 0 else {
            return nil
        }
        return localURL
    }

    func readLocalText(bookId: String) -> String? {
        guard let url = localFileURL(for: bookId) else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }
}
