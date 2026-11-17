import Foundation

struct OpenLibrarySearchResponse: Decodable, Sendable {
    let docs: [OpenLibraryBook]
}

struct OpenLibraryBook: Decodable, Sendable {
    let key: String?
    let title: String?
    let subtitle: String?
    let authorName: [String]?
    let authorKey: [String]?
    let firstPublishYear: Int?
    let coverId: Int?
    let ratingsAverage: Double?
    let ratingsCount: Int?
    let numberOfPagesMedian: Int?
    let publisher: [String]?
    let publicScanB: Bool?
    let ebookAccess: String?
    let ia: [String]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case subtitle
        case authorName = "author_name"
        case authorKey = "author_key"
        case firstPublishYear = "first_publish_year"
        case coverId = "cover_i"
        case ratingsAverage = "ratings_average"
        case ratingsCount = "ratings_count"
        case numberOfPagesMedian = "number_of_pages_median"
        case publisher
        case publicScanB = "public_scan_b"
        case ebookAccess = "ebook_access"
        case ia
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try? container.decodeIfPresent(String.self, forKey: .key)
        self.title = try? container.decodeIfPresent(String.self, forKey: .title)
        self.subtitle = try? container.decodeIfPresent(String.self, forKey: .subtitle)
        self.authorName = try? container.decodeIfPresent([String].self, forKey: .authorName)
        self.authorKey = try? container.decodeIfPresent([String].self, forKey: .authorKey)
        self.firstPublishYear = try? container.decodeIfPresent(Int.self, forKey: .firstPublishYear)
        self.coverId = try? container.decodeIfPresent(Int.self, forKey: .coverId)
        self.ratingsAverage = try? container.decodeIfPresent(Double.self, forKey: .ratingsAverage)
        self.ratingsCount = try? container.decodeIfPresent(Int.self, forKey: .ratingsCount)
        self.numberOfPagesMedian = try? container.decodeIfPresent(Int.self, forKey: .numberOfPagesMedian)
        if let pubs = try? container.decodeIfPresent([String].self, forKey: .publisher) {
            self.publisher = Array(pubs.prefix(12))
        } else {
            self.publisher = nil
        }
        self.publicScanB = try? container.decodeIfPresent(Bool.self, forKey: .publicScanB)
        self.ebookAccess = try? container.decodeIfPresent(String.self, forKey: .ebookAccess)
        if let iaList = try? container.decodeIfPresent([String].self, forKey: .ia) {
            self.ia = Array(iaList.prefix(3))
        } else {
            self.ia = nil
        }
    }
}

enum FlexibleTextValue: Decodable, Sendable {
    case text(String)
    case object(String)
    
    enum CodingKeys: String, CodingKey {
        case value
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
            return
        }
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let value = try keyedContainer.decode(String.self, forKey: .value)
        self = .object(value)
    }
    
    nonisolated var textValue: String {
        switch self {
        case .text(let value), .object(let value):
            return value
        }
    }
}

struct OpenLibraryWorkDetail: Decodable, Sendable {
    let description: FlexibleTextValue?
    let covers: [Int]?
}

struct WorkDetailInfo: Sendable {
    let description: String?
    let coverIDs: [Int]
}

struct OpenLibraryAuthorResponse: Decodable, Sendable {
    let name: String?
    let personalName: String?
    let birthDate: String?
    let deathDate: String?
    let bio: FlexibleTextValue?
    let photos: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case personalName = "personal_name"
        case birthDate = "birth_date"
        case deathDate = "death_date"
        case bio
        case photos
    }
}

struct AuthorDetail: Sendable {
    let authorKey: String
    let name: String
    let personalName: String?
    let birthDate: String?
    let deathDate: String?
    let bio: String?
    let photoIDs: [Int]
    
    var photoURL: URL? {
        if let firstPhoto = photoIDs.first(where: { $0 > 0 }) {
            return URL(string: "https://covers.openlibrary.org/a/id/\(firstPhoto)-M.jpg")
        }
        let cleanKey = authorKey
            .replacingOccurrences(of: "/authors/", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanKey.isEmpty else { return nil }
        return URL(string: "https://covers.openlibrary.org/a/olid/\(cleanKey)-M.jpg?default=false")
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "La URL proporcionada es inválida."
        case .networkError(let error): return "Error de red: \(error.localizedDescription)"
        case .invalidResponse: return "Respuesta inválida del servidor."
        case .decodingError(let error): return "Error al procesar los datos: \(error.localizedDescription)"
        case .noResults: return "No se encontraron libros."
        }
    }
}

class OpenLibraryService {
    private static var workCache: [String: WorkDetailInfo] = [:]
    private static var authorCache: [String: AuthorDetail] = [:]
    private static var searchCache: [String: [OpenLibraryBook]] = [:]
    
    private static let searchFields = "key,title,subtitle,author_name,author_key,cover_i,first_publish_year,ratings_average,ratings_count,number_of_pages_median,publisher,public_scan_b,ebook_access,ia"
    
    private static let fastSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 12
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 150 * 1024 * 1024
        )
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
    
    func searchBooks(query: String) async throws -> [Book] {
        let sanitized = Self.sanitizeSearchQuery(query)
        guard !sanitized.isEmpty else { return [] }
        
        let cacheKey = sanitized.lowercased()
        if let cachedDocs = Self.searchCache[cacheKey] {
            return Self.mapDocsToBooks(cachedDocs)
        }
        
        guard let url = Self.buildSearchURL(queryItems: [
            URLQueryItem(name: "q", value: sanitized),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "fields", value: Self.searchFields)
        ]) else {
            throw APIError.invalidURL
        }
        
        var docs = try await Self.fetchAndDecodeDocs(from: url, requireCover: false)
        
        // Si la búsqueda con acentos o caracteres especiales no dio resultados,
        // reintentamos automáticamente con texto normalizado sin diacríticos.
        if docs.isEmpty {
            let folded = sanitized.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            if folded != sanitized,
               let fallbackURL = Self.buildSearchURL(queryItems: [
                   URLQueryItem(name: "q", value: folded),
                   URLQueryItem(name: "limit", value: "20"),
                   URLQueryItem(name: "fields", value: Self.searchFields)
               ]) {
                docs = (try? await Self.fetchAndDecodeDocs(from: fallbackURL, requireCover: false)) ?? []
            }
        }
        
        if !docs.isEmpty {
            Self.searchCache[cacheKey] = docs
        }
        return Self.mapDocsToBooks(docs)
    }
    
    func fetchBooksByCategory(querySlug: String, limit: Int = 14, maxCount: Int? = nil) async throws -> [Book] {
        let url: URL?
        var requireReadable = false
        var minimumRatingsCount: Int? = nil
        var sortByRating = false
        
        if querySlug == "lectura_libre" {
            requireReadable = true
            let readableLimit = max(limit, 20)
            url = Self.buildSearchURL(queryItems: [
                URLQueryItem(name: "q", value: "language:spa AND ebook_access:public"),
                URLQueryItem(name: "has_fulltext", value: "true"),
                URLQueryItem(name: "limit", value: "\(readableLimit)"),
                URLQueryItem(name: "fields", value: Self.searchFields)
            ])
        } else if querySlug == "mejores_calificados" {
            minimumRatingsCount = 100
            sortByRating = true
            let topLimit = max(limit, 32)
            url = Self.buildSearchURL(queryItems: [
                URLQueryItem(name: "q", value: "ratings_count:[100 TO *]"),
                URLQueryItem(name: "sort", value: "rating"),
                URLQueryItem(name: "limit", value: "\(topLimit)"),
                URLQueryItem(name: "fields", value: Self.searchFields)
            ])
        } else {
            url = Self.buildSearchURL(queryItems: [
                URLQueryItem(name: "subject", value: querySlug),
                URLQueryItem(name: "language", value: "spa"),
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "fields", value: Self.searchFields)
            ])
        }
        
        guard let validURL = url else {
            throw APIError.invalidURL
        }
        
        let effectiveMax = (querySlug == "mejores_calificados") ? (maxCount != nil ? 20 : nil) : maxCount
        let docs = try await Self.fetchAndDecodeDocs(
            from: validURL,
            requireCover: true,
            requireReadable: requireReadable,
            minimumRatingsCount: minimumRatingsCount,
            sortByRating: sortByRating,
            maxCount: effectiveMax
        )
        
        if docs.isEmpty {
            throw APIError.noResults
        }
        
        return Self.mapDocsToBooks(docs)
    }
    
    nonisolated private static func sanitizeSearchQuery(_ raw: String) -> String {
        let forbidden = CharacterSet(charactersIn: ":\"()[]{}^~*?\\&|!+-")
        let cleanedScalars = raw.unicodeScalars.map { forbidden.contains($0) ? " " : String($0) }.joined()
        let components = cleanedScalars
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return components.joined(separator: " ")
    }
    
    nonisolated private static func buildSearchURL(queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents(string: "https://openlibrary.org/search.json")
        components?.queryItems = queryItems
        return components?.url
    }
    
    nonisolated private static func fetchAndDecodeDocs(
        from url: URL,
        requireCover: Bool,
        requireReadable: Bool = false,
        minimumRatingsCount: Int? = nil,
        sortByRating: Bool = false,
        maxCount: Int? = nil
    ) async throws -> [OpenLibraryBook] {
        do {
            let (data, response) = try await fastSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let searchResponse = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
            
            var filteredDocs = searchResponse.docs.filter { doc in
                guard let title = doc.title?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
                    return false
                }
                if requireCover && doc.coverId == nil {
                    return false
                }
                if requireReadable {
                    let hasIA = !(doc.ia?.isEmpty ?? true)
                    let isReadable = (doc.publicScanB == true) || (doc.ebookAccess == "public") || (doc.ebookAccess == "borrowable")
                    if !(hasIA && isReadable) {
                        return false
                    }
                }
                if let minRatings = minimumRatingsCount {
                    if (doc.ratingsCount ?? 0) < minRatings {
                        return false
                    }
                }
                return true
            }
            
            if sortByRating {
                filteredDocs.sort { ($0.ratingsAverage ?? 0) > ($1.ratingsAverage ?? 0) }
            }
            
            if let maxCount {
                return Array(filteredDocs.prefix(maxCount))
            }
            return filteredDocs
            
        } catch let error as APIError {
            throw error
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private static func mapDocsToBooks(_ docs: [OpenLibraryBook]) -> [Book] {
        let books: [Book] = docs.compactMap { doc in
            guard let rawTitle = doc.title?.trimmingCharacters(in: .whitespacesAndNewlines), !rawTitle.isEmpty else {
                return nil
            }
            let coverURLString = doc.coverId.map { "https://covers.openlibrary.org/b/id/\($0)-M.jpg" }
            return Book(
                title: rawTitle,
                subtitle: doc.subtitle,
                author: doc.authorName?.first ?? "Autor Desconocido",
                synopsis: "Publicado por primera vez en \(doc.firstPublishYear.map(String.init) ?? "fecha desconocida").",
                isFavorite: false,
                coverURLString: coverURLString,
                workKey: doc.key,
                firstPublishYear: doc.firstPublishYear,
                coverId: doc.coverId,
                authorKeys: doc.authorKey,
                ratingsAverage: doc.ratingsAverage,
                ratingsCount: doc.ratingsCount,
                numberOfPages: doc.numberOfPagesMedian,
                publishers: doc.publisher,
                isPublicScan: doc.publicScanB,
                ebookAccess: doc.ebookAccess,
                iaIdentifiers: doc.ia
            )
        }
        return books
    }
    
    func fetchWorkDetail(workKey: String) async throws -> WorkDetailInfo {
        let normalizedKey = workKey.hasPrefix("/") ? workKey : "/\(workKey)"
        
        if let cached = Self.workCache[normalizedKey] {
            return cached
        }
        
        guard let url = URL(string: "https://openlibrary.org\(normalizedKey).json") else {
            throw APIError.invalidURL
        }
        
        let info = try await Self.fetchAndDecodeWork(from: url)
        Self.workCache[normalizedKey] = info
        return info
    }
    
    nonisolated private static func fetchAndDecodeWork(from url: URL) async throws -> WorkDetailInfo {
        let (data, response) = try await fastSession.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let detail = try JSONDecoder().decode(OpenLibraryWorkDetail.self, from: data)
        let text = detail.description?.textValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let validText = (text?.isEmpty == false) ? text : nil
        let validCovers = (detail.covers ?? []).filter { $0 > 0 }
        return WorkDetailInfo(description: validText, coverIDs: validCovers)
    }
    
    func fetchAuthorDetail(authorKey: String, fallbackName: String) async throws -> AuthorDetail {
        let cleanKey = authorKey
            .replacingOccurrences(of: "/authors/", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let cached = Self.authorCache[cleanKey] {
            return cached
        }
        
        guard !cleanKey.isEmpty,
              let url = URL(string: "https://openlibrary.org/authors/\(cleanKey).json") else {
            throw APIError.invalidURL
        }
        
        let detail = try await Self.fetchAndDecodeAuthor(from: url, cleanKey: cleanKey, fallbackName: fallbackName)
        Self.authorCache[cleanKey] = detail
        return detail
    }
    
    nonisolated private static func fetchAndDecodeAuthor(from url: URL, cleanKey: String, fallbackName: String) async throws -> AuthorDetail {
        let (data, response) = try await fastSession.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let decoded = try JSONDecoder().decode(OpenLibraryAuthorResponse.self, from: data)
        let bioText = decoded.bio?.textValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return AuthorDetail(
            authorKey: cleanKey,
            name: decoded.name ?? fallbackName,
            personalName: decoded.personalName,
            birthDate: decoded.birthDate,
            deathDate: decoded.deathDate,
            bio: (bioText?.isEmpty == false) ? bioText : nil,
            photoIDs: (decoded.photos ?? []).filter { $0 > 0 }
        )
    }
}
