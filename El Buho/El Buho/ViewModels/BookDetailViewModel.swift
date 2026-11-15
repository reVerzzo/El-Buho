import Foundation
import SwiftData

@MainActor
@Observable
class BookDetailViewModel {
    var book: Book
    var isLoadingDescription: Bool = false
    private var modelContext: ModelContext
    private let apiService = OpenLibraryService()
    private var hasLoadedDescription: Bool = false
    
    init(book: Book, modelContext: ModelContext) {
        let service = BookService(context: modelContext)
        let isSaved = !(service.searchBook(title: book.title)?.isEmpty ?? true)
        book.isFavorite = isSaved
        self.book = book
        self.modelContext = modelContext
    }
    
    func loadDescriptionIfNeeded() async {
        guard !hasLoadedDescription, let workKey = book.workKey else { return }
        hasLoadedDescription = true
        
        let isPlaceholder = book.synopsis.hasPrefix("Publicado por primera vez") || book.synopsis == "Sin descripción disponible."
        guard isPlaceholder else { return }
        
        isLoadingDescription = true
        
        do {
            if let description = try await apiService.fetchBookDescription(workKey: workKey) {
                book.synopsis = description
                if book.isFavorite {
                    let service = BookService(context: modelContext)
                    if let savedBooks = service.searchBook(title: book.title) {
                        for saved in savedBooks {
                            saved.synopsis = description
                        }
                    }
                    try? modelContext.save()
                }
            }
        } catch {
            // Conservamos la sinopsis actual si falla la red
        }
        
        isLoadingDescription = false
    }
    
    func toggleFavoritePersistence() {
        let service = BookService(context: modelContext)
        let newFavoriteState = !book.isFavorite
        book.isFavorite = newFavoriteState
        
        if newFavoriteState {
            if service.searchBook(title: book.title)?.isEmpty ?? true {
                let persistedCopy = Book(
                    id: book.id,
                    title: book.title,
                    author: book.author,
                    synopsis: book.synopsis,
                    isFavorite: true,
                    coverURLString: book.coverURLString,
                    workKey: book.workKey
                )
                service.saveBook(book: persistedCopy)
            }
        } else {
            // Si self.book es una instancia administrada por SwiftData, creamos una copia en memoria
            // antes de borrarla del contexto para que la vista actual nunca lea un objeto eliminado.
            let detachedCopy = Book(
                id: book.id,
                title: book.title,
                author: book.author,
                synopsis: book.synopsis,
                isFavorite: false,
                coverURLString: book.coverURLString,
                workKey: book.workKey
            )
            self.book = detachedCopy
            
            if let savedBooks = service.searchBook(title: detachedCopy.title) {
                for savedBook in savedBooks {
                    service.removeBook(book: savedBook)
                }
            }
        }
    }
}