import Foundation

struct BookSearcher {
    static func filterIndices(for books: [Book], with searchText: String) -> [Int] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return Array(books.indices) }

        return books.indices.filter { index in
            books[index].title.localizedCaseInsensitiveContains(query)
                || books[index].author.localizedCaseInsensitiveContains(query)
        }
    }
}