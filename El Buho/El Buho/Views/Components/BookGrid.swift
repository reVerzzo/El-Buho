import SwiftUI
import SwiftData 

struct DraggedBookSnapshot: Equatable {
    let id: UUID
    let title: String
    let coverURL: URL?
}

struct BookGrid: View {
    @Binding var books: [Book]
    var indices: [Int] = []
    var isEditing: Bool = false
    var selectedBookIDs: Set<UUID> = []
    var onSelectBook: ((Book) -> Void)? = nil
    var draggedBookID: UUID? = nil
    var onDragChanged: ((DraggedBookSnapshot, CGPoint) -> Void)? = nil
    var onDragEnded: ((DraggedBookSnapshot, CGPoint) -> Void)? = nil
    var onTapBook: ((Book) -> Void)? = nil
    
    @Environment(\.modelContext) private var context
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 14),
        count: 3
    )
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 22) {
            ForEach(books, id: \.id) { book in
                let snapshot = DraggedBookSnapshot(
                    id: book.id,
                    title: book.title,
                    coverURL: book.coverURL
                )
                if isEditing {
                    Button {
                        onSelectBook?(book)
                    } label: {
                        BookCell(
                            title: snapshot.title,
                            coverURL: snapshot.coverURL,
                            isEditing: true,
                            isSelected: selectedBookIDs.contains(snapshot.id)
                        )
                    }
                    .buttonStyle(.plain)
                } else if let onTapBook {
                    Button {
                        onTapBook(book)
                    } label: {
                        BookCell(
                            title: snapshot.title,
                            coverURL: snapshot.coverURL
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(destination: BookDetailView(book: book, modelContext: context)) {
                        BookCell(
                            title: snapshot.title,
                            coverURL: snapshot.coverURL
                        )
                        .opacity(draggedBookID == snapshot.id ? 0.25 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        dragGesture(for: snapshot),
                        including: onDragChanged != nil ? .all : .subviews
                    )
                }
            }
        }
    }
    
    private func dragGesture(for snapshot: DraggedBookSnapshot) -> some Gesture {
        LongPressGesture(minimumDuration: 0.35)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .named("FavoriteArea")))
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    if let location = drag?.location {
                        onDragChanged?(snapshot, location)
                    } else {
                        onDragChanged?(snapshot, .zero)
                    }
                default:
                    break
                }
            }
            .onEnded { value in
                switch value {
                case .second(true, let drag):
                    onDragEnded?(snapshot, drag?.location ?? .zero)
                default:
                    break
                }
            }
    }
}
