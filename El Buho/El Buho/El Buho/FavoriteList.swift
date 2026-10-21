//
//  FavoriteList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct FavoriteListView: View {
    @Binding var books: [Book]

    private var favoriteIndices: [Int] {
        books.indices.filter { books[$0].isFavorite }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    BookGrid(books: $books, indices: favoriteIndices)
                        .padding()
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.inline)
         
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
        }
    }
}

struct FavoriteListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteListView(books: .constant([Book(title: "Libro de prueba")]))
    }
}
