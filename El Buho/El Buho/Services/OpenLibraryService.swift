import Foundation

struct OpenLibrarySearchResponse: Decodable {
    let docs: [OpenLibraryBook]
}

struct OpenLibraryBook: Decodable {
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
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
    func searchBooks(query: String) async throws -> [Book] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://openlibrary.org/search.json?q=\(encodedQuery)&limit=20") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(OpenLibrarySearchResponse.self, from: data)
            
            if searchResponse.docs.isEmpty {
                throw APIError.noResults
            }
            
            // Mapeamos la respuesta de la API (OpenLibraryBook) a tu modelo de SwiftData (Book)
            let books = searchResponse.docs.map { doc in
                Book(
                    title: doc.title,
                    author: doc.authorName?.first ?? "Autor Desconocido",
                    synopsis: "Publicado por primera vez en \(doc.firstPublishYear.map(String.init) ?? "fecha desconocida").",
                    isFavorite: false // Por defecto, no es favorito al buscar
                )
            }
            return books
            
        } catch let error as DecodingError {
             throw APIError.decodingError(error)
        } catch {
             throw APIError.networkError(error)
        }
    }
}