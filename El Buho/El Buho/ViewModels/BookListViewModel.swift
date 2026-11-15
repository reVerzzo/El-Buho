import Foundation
import Observation
import SwiftData

enum BookCategory: String, CaseIterable, Identifiable, Hashable {
    case novela
    case ficcion
    case cienciaFiccion
    case fantasia
    case terror
    case historia
    case biografia
    case poesia
    case literatura
    case romance
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .novela: return "Novela"
        case .ficcion: return "Ficción"
        case .cienciaFiccion: return "Ciencia ficción"
        case .fantasia: return "Fantasía"
        case .terror: return "Terror y misterio"
        case .historia: return "Historia"
        case .biografia: return "Biografías"
        case .poesia: return "Poesía"
        case .literatura: return "Literatura clásica"
        case .romance: return "Romance"
        }
    }
    
    var querySlug: String {
        switch self {
        case .novela: return "novela"
        case .ficcion: return "ficcion"
        case .cienciaFiccion: return "ciencia_ficcion"
        case .fantasia: return "fantasia"
        case .terror: return "terror"
        case .historia: return "historia"
        case .biografia: return "biografia"
        case .poesia: return "poesia"
        case .literatura: return "literatura"
        case .romance: return "romance"
        }
    }
}

@MainActor
@Observable
class BookListViewModel {
    var booksByCategory: [String: [Book]] = [:]
    var loadingCategories: Set<String> = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let apiService = OpenLibraryService()
    private var hasLoadedInitial: Bool = false
    
    func books(for category: BookCategory) -> [Book]? {
        booksByCategory[category.querySlug]
    }
    
    func isCategoryLoading(_ category: BookCategory) -> Bool {
        loadingCategories.contains(category.querySlug)
    }
    
    func loadBooksIfNeeded(modelContext: ModelContext, onSuccess: @escaping ([Book]) -> Void) async {
        guard !hasLoadedInitial else { return }
        hasLoadedInitial = true
        await fetchInitialCategories(modelContext: modelContext, onSuccess: onSuccess)
    }
    
    func retry(modelContext: ModelContext, onSuccess: @escaping ([Book]) -> Void) async {
        hasLoadedInitial = true
        booksByCategory.removeAll()
        loadingCategories.removeAll()
        await fetchInitialCategories(modelContext: modelContext, onSuccess: onSuccess)
    }
    
    func loadCategoryIfNeeded(_ category: BookCategory, modelContext: ModelContext, onSuccess: @escaping ([Book]) -> Void) async {
        let slug = category.querySlug
        guard booksByCategory[slug] == nil, !loadingCategories.contains(slug) else { return }
        
        loadingCategories.insert(slug)
        let favoriteTitles = fetchFavoriteTitles(modelContext: modelContext)
        
        do {
            let books = try await apiService.fetchBooksByCategory(
                querySlug: slug,
                limit: 16,
                maxCount: 10
            )
            for book in books where favoriteTitles.contains(book.title) {
                book.isFavorite = true
            }
            booksByCategory[slug] = books
            loadingCategories.remove(slug)
            onSuccess(allCachedBooks)
        } catch {
            loadingCategories.remove(slug)
        }
    }
    
    private func fetchInitialCategories(modelContext: ModelContext, onSuccess: @escaping ([Book]) -> Void) async {
        isLoading = true
        errorMessage = nil
        
        let initialCategories = Array(BookCategory.allCases.prefix(3))
        for category in initialCategories {
            loadingCategories.insert(category.querySlug)
        }
        
        let favoriteTitles = fetchFavoriteTitles(modelContext: modelContext)
        var firstError: Error?
        
        await withTaskGroup(of: (BookCategory, Result<[Book], Error>).self) { group in
            for category in initialCategories {
                let slug = category.querySlug
                group.addTask {
                    do {
                        let books = try await self.apiService.fetchBooksByCategory(
                            querySlug: slug,
                            limit: 16,
                            maxCount: 10
                        )
                        return (category, .success(books))
                    } catch {
                        return (category, .failure(error))
                    }
                }
            }
            
            for await (category, result) in group {
                let slug = category.querySlug
                loadingCategories.remove(slug)
                switch result {
                case .success(let books):
                    for book in books where favoriteTitles.contains(book.title) {
                        book.isFavorite = true
                    }
                    booksByCategory[slug] = books
                    isLoading = false
                case .failure(let error):
                    if firstError == nil {
                        firstError = error
                    }
                }
            }
        }
        
        if booksByCategory.isEmpty, let firstError {
            errorMessage = firstError.localizedDescription
            isLoading = false
            return
        }
        
        onSuccess(allCachedBooks)
        isLoading = false
    }
    
    private var allCachedBooks: [Book] {
        BookCategory.allCases.compactMap { booksByCategory[$0.querySlug] }.flatMap { $0 }
    }
    
    private func fetchFavoriteTitles(modelContext: ModelContext) -> Set<String> {
        let dbService = BookService(context: modelContext)
        let savedFavorites = dbService.fetchBooks() ?? []
        return Set(savedFavorites.map(\.title))
    }
}
