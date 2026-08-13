import FirebaseFirestore

struct FirestoreRepository {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    func fetchAuthors() async throws -> [Author] {
        let snapshot = try await firestore.collection("authors").getDocuments()
        return snapshot.documents.compactMap { document in
            guard let name = document.data()["name"] as? String else { return nil }
            let bookCount = document.data()["bookCount"] as? Int
                ?? (document.data()["bookCount"] as? NSNumber)?.intValue
                ?? 0
            return Author(id: document.documentID, name: name, bookCount: bookCount)
        }
        .sorted { $0.name < $1.name }
    }

    func fetchBooks() async throws -> [Book] {
        let snapshot = try await firestore.collection("books").getDocuments()
        return snapshot.documents.map { document in
            let data = document.data()
            return Book(
                id: document.documentID,
                author: data["author"] as? String ?? "",
                title: data["title"] as? String ?? "",
                filename: data["filename"] as? String ?? "",
                storagePath: data["storagePath"] as? String ?? "",
                source: data["source"] as? String ?? "",
                searchTitle: data["searchTitle"] as? String ?? "",
                searchAuthor: data["searchAuthor"] as? String ?? ""
            )
        }
        .sorted {
            if $0.author == $1.author {
                return $0.title < $1.title
            }
            return $0.author < $1.author
        }
    }
}
