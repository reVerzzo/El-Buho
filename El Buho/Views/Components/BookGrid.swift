import SwiftUI

struct BookGrid: View {
    @Binding var books: [Book]
    let indices: [Int]

    private let columns = Array(
        repeating: GridItem(.flexible()),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(indices, id: \.self) { index in
                NavigationLink(destination: BookDetailView(book: $books[index])) {
                    BookCell(title: books[index].title)
                }
            }
        }
    }
}