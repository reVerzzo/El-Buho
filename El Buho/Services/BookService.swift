//
//  BookService.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 29/10/26.
//

import Foundation
import SwiftData

protocol BookServiceProtocol {
    func fetchBooks() -> [Book]?
    func saveBook(book: Book)
    func removeBook(book: Book)
}

class BookService: BookServiceProtocol {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchBooks() -> [Book]? {
        try? context.fetch(FetchDescriptor<Book>())
    }

    func searchBook(title: String) -> [Book]? {
        let description = FetchDescriptor<Book>(
            predicate: #Predicate {
                $0.title == title
            }
        )

        let searchedBook = try? context.fetch(description)
        return searchedBook
    }
    
    func saveBook(book: Book) {
        context.insert(book)
        save()
    }

    func removeBook(book: Book) {
        context.delete(book)
        save()
    }

    private func save() {
        do {
            try context.save()
        } catch {
            print("Hubo un error")
        }
    }
}

struct MockBookService: BookServiceProtocol {
    func fetchBooks() -> [Book]? {
        return [
            Book(title: "La Sombra del Búho", author: "Autor 1", isFavorite: true),
            Book(title: "El Secreto del Lector", author: "Autor 2", isFavorite: true)
        ]
    }
    
    func saveBook(book: Book) {}
    func removeBook(book: Book) {}
}
