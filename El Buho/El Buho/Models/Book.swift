import Foundation
import SwiftData

@Model
class Book: Identifiable, Equatable {
    var id: UUID
    var title: String
    var author: String
    var synopsis: String
    var isFavorite: Bool
    var coverURLString: String?
    var workKey: String?
    
    var coverURL: URL? {
        guard let coverURLString else { return nil }
        return URL(string: coverURLString)
    }
    
    var largeCoverURL: URL? {
        guard let coverURLString else { return nil }
        let largeString = coverURLString.replacingOccurrences(of: "-M.jpg", with: "-L.jpg")
        return URL(string: largeString)
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String = "Autor Desconocido",
        synopsis: String = "Sin descripción disponible.",
        isFavorite: Bool = false,
        coverURLString: String? = nil,
        workKey: String? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.synopsis = synopsis
        self.isFavorite = isFavorite
        self.coverURLString = coverURLString
        self.workKey = workKey
    }
}

extension Book {
    static let bookTest = Book(title: "Libro de prueba", author: "Autor", isFavorite: true)
}
