import Foundation
import SwiftData

@Model
class Book: Identifiable, Equatable {
    var id: UUID
    var title: String
    var author: String
    var synopsis: String
    var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String = "Autor Desconocido",
        synopsis: String = "Sin descripción disponible.",
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.synopsis = synopsis
        self.isFavorite = isFavorite
    }
}

extension Book {
    static let bookTest = Book(title: "Libro de prueba", author: "Autor", isFavorite: true)
}
