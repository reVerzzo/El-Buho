import Foundation
import Observation
import SwiftData
import SwiftUI

struct RecentBookDTO: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var author: String
    var synopsis: String
    var coverURLString: String?
    var workKey: String?
    
    init(from book: Book) {
        self.id = book.id
        self.title = book.title
        self.author = book.author
        self.synopsis = book.synopsis
        self.coverURLString = book.coverURLString
        self.workKey = book.workKey
    }
    
    func toBook() -> Book {
        Book(
            id: id,
            title: title,
            author: author,
            synopsis: synopsis,
            isFavorite: false,
            coverURLString: coverURLString,
            workKey: workKey
        )
    }
}

@MainActor
@Observable
class BookSearcher {
    var searchText: String = ""
    var searchResults: [Book] = []
    var recentBooks: [Book] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let apiService = OpenLibraryService()
    private var searchTask: Task<Void, Never>? = nil
    private let recentBooksKey = "ElBuho.RecentSearchedBooks.v2"
    private let maxRecentBooks = 12
    
    init() {
        loadRecentBooks()
    }
    
    func handleSearchTextChange(_ newValue: String) {
        searchTask?.cancel()
        
        let cleanQuery = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else {
            searchResults = []
            errorMessage = nil
            isLoading = false
            return
        }
        
        searchTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await executeSearch(query: cleanQuery)
        }
    }
    
    func performSearch() {
        searchTask?.cancel()
        
        let cleanQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else {
            searchResults = []
            errorMessage = nil
            isLoading = false
            return
        }
        
        searchTask = Task { @MainActor in
            await executeSearch(query: cleanQuery)
        }
    }
    
    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        searchResults = []
        errorMessage = nil
        isLoading = false
    }
    
    func recordRecentBook(_ book: Book) {
        var currentDTOs = fetchSavedDTOs()
        currentDTOs.removeAll { existing in
            if existing.id == book.id { return true }
            if let existingKey = existing.workKey, let bookKey = book.workKey, existingKey == bookKey {
                return true
            }
            return existing.title.caseInsensitiveCompare(book.title) == .orderedSame
        }
        currentDTOs.insert(RecentBookDTO(from: book), at: 0)
        if currentDTOs.count > maxRecentBooks {
            currentDTOs = Array(currentDTOs.prefix(maxRecentBooks))
        }
        saveDTOs(currentDTOs)
        recentBooks = currentDTOs.map { $0.toBook() }
    }
    
    func clearRecentBooks() {
        UserDefaults.standard.removeObject(forKey: recentBooksKey)
        recentBooks = []
    }
    
    private func executeSearch(query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await apiService.searchBooks(query: query)
            guard !Task.isCancelled else { return }
            
            let currentTrimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !currentTrimmed.isEmpty else {
                searchResults = []
                isLoading = false
                return
            }
            
            searchResults = results
            isLoading = false
        } catch is CancellationError {
            // Ignoramos cancelaciones por debounce
        } catch let error as APIError {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
            isLoading = false
        } catch {
            guard !Task.isCancelled else { return }
            if (error as NSError).code == NSURLErrorCancelled {
                return
            }
            errorMessage = "Ocurrió un error inesperado al buscar los libros."
            isLoading = false
        }
    }
    
    private func loadRecentBooks() {
        let dtos = fetchSavedDTOs()
        recentBooks = dtos.map { $0.toBook() }
    }
    
    private func fetchSavedDTOs() -> [RecentBookDTO] {
        guard let data = UserDefaults.standard.data(forKey: recentBooksKey),
              let decoded = try? JSONDecoder().decode([RecentBookDTO].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveDTOs(_ dtos: [RecentBookDTO]) {
        if let data = try? JSONEncoder().encode(dtos) {
            UserDefaults.standard.set(data, forKey: recentBooksKey)
        }
    }
}
