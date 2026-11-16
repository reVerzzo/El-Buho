import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
class FavoriteListViewModel {
    var persistedFavorites: [Book] = []
    var isEditing: Bool = false
    var selectedBookIDs: Set<UUID> = []
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadFavoritesFromDatabase() {
        let service = BookService(context: modelContext)
        let dbBooks = service.fetchBooks() ?? []
        
        // Creamos copias desacopladas para la vista para evitar que SwiftUI observe objetos
        // que puedan ser destruidos directamente en el ModelContext durante animaciones.
        persistedFavorites = dbBooks.map { dbBook in
            dbBook.detachedCopy(isFavoriteOverride: true)
        }
    }
    
    func toggleEditing() {
        isEditing.toggle()
        if !isEditing {
            selectedBookIDs.removeAll()
        }
    }
    
    func toggleSelection(for book: Book) {
        if selectedBookIDs.contains(book.id) {
            selectedBookIDs.remove(book.id)
        } else {
            selectedBookIDs.insert(book.id)
        }
    }
    
    func removeFavorite(id: UUID, title: String) {
        withAnimation(.easeInOut(duration: 0.25)) {
            persistedFavorites.removeAll { $0.id == id || $0.title == title }
            selectedBookIDs.remove(id)
        }
        deleteFromDatabase(id: id, title: title)
    }
    
    func removeSelectedFavorites() {
        let targets = persistedFavorites
            .filter { selectedBookIDs.contains($0.id) }
            .map { (id: $0.id, title: $0.title) }
        let removedIDs = Set(targets.map(\.id))
        
        withAnimation(.easeInOut(duration: 0.25)) {
            persistedFavorites.removeAll { removedIDs.contains($0.id) }
            selectedBookIDs.removeAll()
            isEditing = false
        }
        
        for target in targets {
            deleteFromDatabase(id: target.id, title: target.title)
        }
    }
    
    private func deleteFromDatabase(id: UUID, title: String) {
        let service = BookService(context: modelContext)
        if let allSaved = service.fetchBooks() {
            for saved in allSaved where saved.id == id || saved.title == title {
                modelContext.delete(saved)
            }
            try? modelContext.save()
        }
    }
}