import Foundation
import SwiftData
import SwiftUI

@Observable
class FavoriteListViewModel {
    var persistedFavorites: [Book] = []
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadFavoritesFromDatabase(globalBooks: Binding<[Book]>) {
        let service = BookService(context: modelContext)
        persistedFavorites = service.fetchBooks() ?? []
        
        for index in globalBooks.wrappedValue.indices {
            let isSaved = persistedFavorites.contains { $0.title == globalBooks.wrappedValue[index].title }
            globalBooks.wrappedValue[index].isFavorite = isSaved
        }
    }
}