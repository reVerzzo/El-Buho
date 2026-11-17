//
//  BookService.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 29/10/26.
//

import Foundation
import SwiftData

class BookService {
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
        return try? context.fetch(description)
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
        try? context.save()
    }
}
