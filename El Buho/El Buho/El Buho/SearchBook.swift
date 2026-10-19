//
//  SearchBook.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct SearchBookView: View {
    @Binding var books: [Book]

    @State private var searchText: String = ""

    private var matchingIndices: [Int] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return Array(books.indices) }

        return books.indices.filter { index in
            books[index].title.localizedCaseInsensitiveContains(query)
                || books[index].author.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
                    TextField("Buscar...", text: $searchText)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(AppColors.primaryText)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("Recientes:")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ScrollView {
                        BookGrid(books: $books, indices: matchingIndices)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Búsqueda")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SearchBookView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBookView(books: .constant([Book(title: "Libro de prueba")]))
    }
}
