import Foundation
import Observation
import SwiftData

@Observable
class BookSearcher {
    var searchText: String = ""
    var searchResults: [Book] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let apiService = OpenLibraryService()
    
    func performSearch() {
        let cleanQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else {
            searchResults = []
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let results = try await apiService.searchBooks(query: cleanQuery)
                await MainActor.run {
                    self.searchResults = results
                    self.isLoading = false
                }
            } catch let error as APIError {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Ocurrió un error inesperado al buscar los libros."
                    self.isLoading = false
                }
            }
        }
    }
}