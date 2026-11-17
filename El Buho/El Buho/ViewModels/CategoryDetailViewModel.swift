import Foundation
import Observation
import SwiftData

@Observable
class CategoryDetailViewModel {
    let category: BookCategory
    var books: [Book] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let apiService = OpenLibraryService()
    private var hasLoaded: Bool = false
    
    init(category: BookCategory) {
        self.category = category
    }
    
    func loadBooksIfNeeded(modelContext: ModelContext) async {
        guard !hasLoaded else { return }
        await fetchBooks(modelContext: modelContext)
    }
    
    func retry(modelContext: ModelContext) async {
        hasLoaded = false
        await fetchBooks(modelContext: modelContext)
    }
    
    private func fetchBooks(modelContext: ModelContext) async {
        let favoriteTitles: Set<String> = await MainActor.run {
            isLoading = true
            errorMessage = nil
            let dbService = BookService(context: modelContext)
            let savedFavorites = dbService.fetchBooks() ?? []
            return Set(savedFavorites.map(\.title))
        }
        
        do {
            let results = try await apiService.fetchBooksByCategory(
                querySlug: category.querySlug,
                limit: 60
            )
            
            await MainActor.run {
                for book in results where favoriteTitles.contains(book.title) {
                    book.isFavorite = true
                }
                self.books = results
                self.hasLoaded = true
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
