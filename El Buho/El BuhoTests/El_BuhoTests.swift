//
//  El_BuhoTests.swift
//  El BuhoTests
//
//  Created by Facultad de Contaduría y Administración on 26/10/26.
//

import Testing
@testable import El_Buho /

@Suite("Pruebas de filtrado y búsqueda de libros")
struct BookSearcherTests {

    // Arreglo de libros simulados que usaremos para las pruebas
    let mockBooks: [Book]

    init() {
        mockBooks = [
            Book(title: "El Imperio Final", author: "Brandon Sanderson"),
            Book(title: "1984", author: "George Orwell"),
            Book(title: "Dune", author: "Frank Herbert")
        ]
    }

    //Caso Normal
    @Test("Búsqueda válida por título devuelve el índice correcto")
    func validTitleSearch() {
        // Arrange
        let query = "Imperio"
        
        // Act
        let result = BookSearcher.filterIndices(for: mockBooks, with: query)
        
        // Assert
        #expect(result.count == 1, "Debería encontrar exactamente 1 coincidencia.")
        
        if let firstIndex = result.first {
            #expect(mockBooks[firstIndex].title == "El Imperio Final", "El libro encontrado debería ser 'El Imperio Final'.")
        }
    }

    // Caso Límite 
    @Test("Búsqueda ignora espacios extra y distingue mayúsculas de minúsculas")
    func mixedCaseAndSpacesSearch() {
        // Arrange
        let query = "   orWeLL   " // Búsqueda desordenada por autor
        
        // Act
        let result = BookSearcher.filterIndices(for: mockBooks, with: query)
        
        // Assert
        #expect(result.count == 1, "Debería encontrar 1 coincidencia ignorando formato.")
        
        if let firstIndex = result.first {
            #expect(mockBooks[firstIndex].author == "George Orwell", "Debería encontrar el libro del autor 'George Orwell'.")
        }
    }

    //Entrada Inválida / Sin Resultados
    @Test("Búsqueda sin coincidencias devuelve un arreglo vacío")
    func noMatchesSearch() {
        // Arrange
        let query = "Harry Potter" // Un libro que no existe en nuestro mock
        
        // Act
        let result = BookSearcher.filterIndices(for: mockBooks, with: query)
        
        // Assert
        #expect(result.isEmpty, "El arreglo de índices debería estar completamente vacío.")
    }
    
    //Caso Extra
    @Test("Búsqueda vacía (solo espacios) devuelve todos los libros")
    func emptySearch() {
        // Arrange
        let query = "   " 
        
        // Act
        let result = BookSearcher.filterIndices(for: mockBooks, with: query)
        
        // Assert
        #expect(result.count == mockBooks.count, "Debería devolver los 3 libros originales.")
    }
}