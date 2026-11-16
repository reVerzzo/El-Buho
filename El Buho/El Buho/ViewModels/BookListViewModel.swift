import Foundation
import Observation
import SwiftData

enum BookCategory: String, CaseIterable, Identifiable, Hashable {
    case lecturaLibre
    case mejoresCalificados
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
        case .lecturaLibre: return "Libros para leer"
        case .mejoresCalificados: return "Mejores calificados"
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
        case .lecturaLibre: return "lectura_libre"
        case .mejoresCalificados: return "mejores_calificados"
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
    
    var homeCarouselLimit: Int {
        self == .mejoresCalificados ? 20 : 10
    }
}

@MainActor
@Observable
class BookListViewModel {
    private static var globalCategoryCache: [String: [Book]] = [:]
    private static let diskCacheURL: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("ElBuhoCatalogCache_v1.json")
    }()
    
    var booksByCategory: [String: [Book]] = [:]
    var loadingCategories: Set<String> = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let apiService = OpenLibraryService()
    private var hasLoadedInitial: Bool = false
    
    init() {
        if !Self.globalCategoryCache.isEmpty {
            self.booksByCategory = Self.globalCategoryCache
            self.hasLoadedInitial = true
        } else if let diskCached = Self.loadCatalogFromDisk(), !diskCached.isEmpty {
            self.booksByCategory = diskCached
            Self.globalCategoryCache = diskCached
        }
    }
    
    func books(for category: BookCategory) -> [Book]? {
        booksByCategory[category.querySlug]
    }
    
    func isCategoryLoading(_ category: BookCategory) -> Bool {
        loadingCategories.contains(category.querySlug)
    }
    
    func loadBooksIfNeeded(modelContext: ModelContext) async {
        guard !hasLoadedInitial else { return }
        hasLoadedInitial = true
        await fetchInitialCategories(modelContext: modelContext)
    }
    
    func retry(modelContext: ModelContext) async {
        hasLoadedInitial = true
        booksByCategory.removeAll()
        Self.globalCategoryCache.removeAll()
        loadingCategories.removeAll()
        await fetchInitialCategories(modelContext: modelContext)
    }
    
    func loadCategoryIfNeeded(_ category: BookCategory, modelContext: ModelContext) async {
        let slug = category.querySlug
        guard booksByCategory[slug] == nil, !loadingCategories.contains(slug) else { return }
        
        loadingCategories.insert(slug)
        let favoriteTitles = fetchFavoriteTitles(modelContext: modelContext)
        
        do {
            let books = try await apiService.fetchBooksByCategory(
                querySlug: slug,
                limit: category == .mejoresCalificados ? 32 : 14,
                maxCount: category.homeCarouselLimit
            )
            for book in books where favoriteTitles.contains(book.title) {
                book.isFavorite = true
            }
            booksByCategory[slug] = books
            Self.globalCategoryCache[slug] = books
            Self.saveCatalogToDisk(Self.globalCategoryCache)
            loadingCategories.remove(slug)
        } catch {
            loadingCategories.remove(slug)
        }
    }
    
    private func fetchInitialCategories(modelContext: ModelContext) async {
        isLoading = booksByCategory.isEmpty
        errorMessage = nil
        
        let initialCategories = Array(BookCategory.allCases.prefix(3))
            .filter { booksByCategory[$0.querySlug] == nil }
        
        guard !initialCategories.isEmpty else {
            isLoading = false
            return
        }
        
        for category in initialCategories {
            loadingCategories.insert(category.querySlug)
        }
        
        let favoriteTitles = fetchFavoriteTitles(modelContext: modelContext)
        var firstError: Error?
        
        await withTaskGroup(of: (BookCategory, Result<[Book], Error>).self) { group in
            for category in initialCategories {
                let slug = category.querySlug
                let maxItems = category.homeCarouselLimit
                let requestLimit = category == .mejoresCalificados ? 32 : 14
                group.addTask {
                    do {
                        let books = try await self.apiService.fetchBooksByCategory(
                            querySlug: slug,
                            limit: requestLimit,
                            maxCount: maxItems
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
                    Self.globalCategoryCache[slug] = books
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
        
        Self.saveCatalogToDisk(Self.globalCategoryCache)
        isLoading = false
    }
    
    private func fetchFavoriteTitles(modelContext: ModelContext) -> Set<String> {
        let dbService = BookService(context: modelContext)
        let savedFavorites = dbService.fetchBooks() ?? []
        return Set(savedFavorites.map(\.title))
    }
    
    private static func loadCatalogFromDisk() -> [String: [Book]]? {
        guard let data = try? Data(contentsOf: diskCacheURL),
              let decoded = try? JSONDecoder().decode([String: [RecentBookDTO]].self, from: data) else {
            return nil
        }
        var result: [String: [Book]] = [:]
        for (slug, dtos) in decoded where !dtos.isEmpty {
            result[slug] = dtos.map { $0.toBook() }
        }
        return result
    }
    
    private static func saveCatalogToDisk(_ catalog: [String: [Book]]) {
        var dtoDict: [String: [RecentBookDTO]] = [:]
        for (slug, books) in catalog {
            dtoDict[slug] = books.map { RecentBookDTO(from: $0) }
        }
        guard let data = try? JSONEncoder().encode(dtoDict) else { return }
        let targetURL = diskCacheURL
        Task.detached(priority: .background) {
            try? data.write(to: targetURL, options: .atomic)
        }
    }
}
