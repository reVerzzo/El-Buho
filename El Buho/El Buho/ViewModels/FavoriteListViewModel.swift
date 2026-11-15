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
    
    func loadFavoritesFromDatabase(globalBooks: Binding<[Book]>) {
        let service = BookService(context: modelContext)
        let dbBooks = service.fetchBooks() ?? []
        
        // Creamos copias desacopladas para la vista para evitar que SwiftUI observe objetos
        // que puedan ser destruidos directamente en el ModelContext durante animaciones.
        persistedFavorites = dbBooks.map { dbBook in
            Book(
                id: dbBook.id,
                title: dbBook.title,
                author: dbBook.author,
                synopsis: dbBook.synopsis,
                isFavorite: true,
                coverURLString: dbBook.coverURLString,
                workKey: dbBook.workKey
            )
        }
        
        let savedTitles = Set(dbBooks.map(\.title))
        for index in globalBooks.wrappedValue.indices {
            globalBooks.wrappedValue[index].isFavorite = savedTitles.contains(globalBooks.wrappedValue[index].title)
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
    
    func removeFavorite(id: UUID, title: String, globalBooks: Binding<[Book]>) {
        withAnimation(.easeInOut(duration: 0.25)) {
            persistedFavorites.removeAll { $0.id == id || $0.title == title }
            selectedBookIDs.remove(id)
        }
        
        for index in globalBooks.wrappedValue.indices {
            if globalBooks.wrappedValue[index].id == id || globalBooks.wrappedValue[index].title == title {
                globalBooks.wrappedValue[index].isFavorite = false
            }
        }
        
        deleteFromDatabase(id: id, title: title)
    }
    
    func removeSelectedFavorites(globalBooks: Binding<[Book]>) {
        let targets = persistedFavorites
            .filter { selectedBookIDs.contains($0.id) }
            .map { (id: $0.id, title: $0.title) }
        let removedIDs = Set(targets.map(\.id))
        let removedTitles = Set(targets.map(\.title))
        
        withAnimation(.easeInOut(duration: 0.25)) {
            persistedFavorites.removeAll { removedIDs.contains($0.id) }
            selectedBookIDs.removeAll()
            isEditing = false
        }
        
        for index in globalBooks.wrappedValue.indices {
            if removedIDs.contains(globalBooks.wrappedValue[index].id) || removedTitles.contains(globalBooks.wrappedValue[index].title) {
                globalBooks.wrappedValue[index].isFavorite = false
            }
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