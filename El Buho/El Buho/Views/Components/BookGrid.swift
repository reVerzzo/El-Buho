import SwiftUI
import SwiftData 

struct BookGrid: View {
    @Binding var books: [Book]
    let indices: [Int]
    
    @Environment(\.modelContext) private var context
    
    private let columns = Array(
        repeating: GridItem(.flexible()),
        count: 3
    )
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(indices, id: \.self) { index in
                NavigationLink(destination: BookDetailView(book: $books[index], modelContext: context)) {
                    BookCell(title: books[index].title)
                }
            }
        }
    }
}