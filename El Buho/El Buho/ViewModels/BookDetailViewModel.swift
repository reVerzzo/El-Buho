import Foundation
import SwiftData

@MainActor
@Observable
class BookDetailViewModel {
    var book: Book
    var coverURLs: [URL] = []
    var isLoadingDescription: Bool = false
    
    var isAuthorSheetPresented: Bool = false
    var authorDetail: AuthorDetail? = nil
    var isLoadingAuthor: Bool = false
    
    var isReaderPresented: Bool = false
    
    private var modelContext: ModelContext
    private let apiService = OpenLibraryService()
    private var hasLoadedWorkDetails: Bool = false
    private var hasLoadedAuthor: Bool = false
    
    init(book: Book, modelContext: ModelContext) {
        let service = BookService(context: modelContext)
        let isSaved = !(service.searchBook(title: book.title)?.isEmpty ?? true)
        book.isFavorite = isSaved
        self.book = book
        self.modelContext = modelContext
        
        if let primaryURL = book.coverURL ?? book.largeCoverURL {
            self.coverURLs = [primaryURL]
        }
    }
    
    func loadDescriptionIfNeeded() async {
        guard !hasLoadedWorkDetails, let workKey = book.workKey else { return }
        hasLoadedWorkDetails = true
        
        let isPlaceholder = book.synopsis.hasPrefix("Publicado por primera vez") || book.synopsis == "Sin descripción disponible."
        if isPlaceholder {
            isLoadingDescription = true
        }
        
        do {
            let workInfo = try await apiService.fetchWorkDetail(workKey: workKey)
            
            if !workInfo.coverIDs.isEmpty {
                var orderedIDs: [Int] = []
                if let mainCoverId = book.coverId, mainCoverId > 0 {
                    orderedIDs.append(mainCoverId)
                }
                for id in workInfo.coverIDs where !orderedIDs.contains(id) {
                    orderedIDs.append(id)
                }
                let urls = orderedIDs.prefix(6).compactMap {
                    URL(string: "https://covers.openlibrary.org/b/id/\($0)-M.jpg")
                }
                if urls.count > self.coverURLs.count {
                    self.coverURLs = urls
                }
            }
            
            if isPlaceholder, let description = workInfo.description {
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
            // Conservamos la portada y sinopsis actuales si falla la red
        }
        
        isLoadingDescription = false
    }
    
    func openAuthorSheet() {
        isAuthorSheetPresented = true
        Task {
            await loadAuthorDetailIfNeeded()
        }
    }
    
    func loadAuthorDetailIfNeeded() async {
        guard !hasLoadedAuthor else { return }
        hasLoadedAuthor = true
        
        guard let firstAuthorKey = book.authorKeys?.first, !firstAuthorKey.isEmpty else {
            authorDetail = AuthorDetail(
                authorKey: "",
                name: book.author,
                personalName: nil,
                birthDate: nil,
                deathDate: nil,
                bio: nil,
                photoIDs: []
            )
            return
        }
        
        isLoadingAuthor = true
        do {
            let detail = try await apiService.fetchAuthorDetail(
                authorKey: firstAuthorKey,
                fallbackName: book.author
            )
            authorDetail = detail
        } catch {
            authorDetail = AuthorDetail(
                authorKey: firstAuthorKey,
                name: book.author,
                personalName: nil,
                birthDate: nil,
                deathDate: nil,
                bio: nil,
                photoIDs: []
            )
        }
        isLoadingAuthor = false
    }
    
    func toggleFavoritePersistence() {
        let service = BookService(context: modelContext)
        let newFavoriteState = !book.isFavorite
        book.isFavorite = newFavoriteState
        
        if newFavoriteState {
            if service.searchBook(title: book.title)?.isEmpty ?? true {
                let persistedCopy = book.detachedCopy(isFavoriteOverride: true)
                service.saveBook(book: persistedCopy)
            }
        } else {
            let detached = book.detachedCopy(isFavoriteOverride: false)
            self.book = detached
            
            if let savedBooks = service.searchBook(title: detached.title) {
                for savedBook in savedBooks {
                    service.removeBook(book: savedBook)
                }
            }
        }
    }
}
