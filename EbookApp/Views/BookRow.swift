import SwiftUI

struct BookRow: View {
    let book: Book
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            BookRowContent(book: book)
        }
        .buttonStyle(.plain)
    }
}

struct BookRowContent: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.title)
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)

            Text(book.author)
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurface.opacity(0.7))

            if !book.source.isEmpty {
                Text(book.source)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
