import Foundation

struct OpenLibrarySearchResponse: Decodable {
    let docs: [OpenLibraryBook]
}

struct OpenLibraryBook: Decodable {
    let key: String?
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverId: Int?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverId = "cover_i"
    }
}

struct OpenLibraryWorkDetail: Decodable {
    let description: DescriptionValue?
    
    enum DescriptionValue: Decodable {
        case text(String)
        case object(String)
        
        enum CodingKeys: String, CodingKey {
            case value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let text = try? container.decode(String.self) {
                self = .text(text)
                return
            }
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            let value = try keyedContainer.decode(String.self, forKey: .value)
            self = .object(value)
        }
        
        var textValue: String {
            switch self {
            case .text(let value), .object(let value):
                return value
            }
        }
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
    private static var descriptionCache: [String: String] = [:]
    private static let searchFields = "key,title,author_name,cover_i,first_publish_year"
    
    func searchBooks(query: String) async throws -> [Book] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://openlibrary.org/search.json?q=\(encodedQuery)&limit=20&fields=\(Self.searchFields)") else {
            throw APIError.invalidURL
        }
        return try await fetchBooks(from: url, requireCover: false)
    }
    
    func fetchBooksByCategory(querySlug: String, limit: Int = 16, maxCount: Int? = nil) async throws -> [Book] {
        guard let encodedSlug = querySlug.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://openlibrary.org/search.json?subject=\(encodedSlug)&language=spa&limit=\(limit)&fields=\(Self.searchFields)") else {
            throw APIError.invalidURL
        }
        return try await fetchBooks(from: url, requireCover: true, maxCount: maxCount)
    }
    
    private func fetchBooks(from url: URL, requireCover: Bool, maxCount: Int? = nil) async throws -> [Book] {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(OpenLibrarySearchResponse.self, from: data)
            
            let filteredDocs = requireCover
                ? searchResponse.docs.filter { $0.coverId != nil }
                : searchResponse.docs
            
            let finalDocs: [OpenLibraryBook]
            if let maxCount {
                finalDocs = Array(filteredDocs.prefix(maxCount))
            } else {
                finalDocs = filteredDocs
            }
            
            if finalDocs.isEmpty {
                throw APIError.noResults
            }
            
            // Usamos tamaño -M.jpg para carga ultrarrápida en listas y carruseles
            let books = finalDocs.map { doc in
                let coverURLString = doc.coverId.map { "https://covers.openlibrary.org/b/id/\($0)-M.jpg" }
                return Book(
                    title: doc.title,
                    author: doc.authorName?.first ?? "Autor Desconocido",
                    synopsis: "Publicado por primera vez en \(doc.firstPublishYear.map(String.init) ?? "fecha desconocida").",
                    isFavorite: false,
                    coverURLString: coverURLString,
                    workKey: doc.key
                )
            }
            return books
            
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
             throw APIError.decodingError(error)
        } catch {
             throw APIError.networkError(error)
        }
    }
    
    func fetchBookDescription(workKey: String) async throws -> String? {
        let normalizedKey = workKey.hasPrefix("/") ? workKey : "/\(workKey)"
        
        if let cached = await MainActor.run(body: { Self.descriptionCache[normalizedKey] }) {
            return cached
        }
        
        guard let url = URL(string: "https://openlibrary.org\(normalizedKey).json") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let detail = try JSONDecoder().decode(OpenLibraryWorkDetail.self, from: data)
        let text = detail.description?.textValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if let validText = text, !validText.isEmpty {
            await MainActor.run {
                Self.descriptionCache[normalizedKey] = validText
            }
            return validText
        }
        return nil
    }
}