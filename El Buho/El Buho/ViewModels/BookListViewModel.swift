import Foundation
import Observation
import SwiftData

@Observable
class BookListViewModel {
    var isProfilePresented: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let apiService = OpenLibraryService()
    private var hasLoadedAPI: Bool = false
    
    func toggleProfilePresentation() {
        isProfilePresented.toggle()
    }
    
    func loadBooksIfNeeded(modelContext: ModelContext, onSuccess: @escaping ([Book]) -> Void) async {
        guard !hasLoadedAPI else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await apiService.searchBooks(query: "classic")
            
            await MainActor.run {
                // Sincronizamos con SwiftData para marcar los que ya son favoritos
                let dbService = BookService(context: modelContext)
                let savedFavorites = dbService.fetchBooks() ?? []
                
                for book in results {
                    if savedFavorites.contains(where: { $0.title == book.title }) {
                        book.isFavorite = true
                    }
                }
                
                onSuccess(results)
                self.hasLoadedAPI = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}