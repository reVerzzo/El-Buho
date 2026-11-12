import Foundation
import SwiftData

@Observable
class BookDetailViewModel {
    var book: Book
    private var modelContext: ModelContext
    
    init(book: Book, modelContext: ModelContext) {
        self.book = book
        self.modelContext = modelContext
    }
    
    func toggleFavoritePersistence() {
        let service = BookService(context: modelContext)
        book.isFavorite.toggle()
        
        if book.isFavorite {
            if service.searchBook(title: book.title)?.isEmpty ?? true {
                service.saveBook(book: book)
            }
        } else {
            if let savedBooks = service.searchBook(title: book.title) {
                for savedBook in savedBooks {
                    service.removeBook(book: savedBook)
                }
            }
        }
    }
}