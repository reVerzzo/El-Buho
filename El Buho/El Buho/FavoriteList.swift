//
//  FavoriteList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

//
//  FavoriteList.swift
//  El Buho
//

import SwiftUI
import SwiftData

struct FavoriteListView: View {
    @Binding var books: [Book]
    
    // Contexto de SwiftData como lo declaró el profesor
    @Environment(\.modelContext) private var modelContext
    
    // Estado local para almacenar los favoritos traídos desde SwiftData
    @State private var persistedFavorites: [Book] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    // Mostramos la cuadrícula con los libros persistidos en SwiftData
                    BookGrid(
                        books: $persistedFavorites,
                        indices: Array(persistedFavorites.indices)
                    )
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
            // Cada vez que entramos a la pestaña, cargamos desde SwiftData usando BookService
            .onAppear {
                loadFavoritesFromDatabase()
            }
        }
    }
    
    private func loadFavoritesFromDatabase() {
        let service = BookService(context: modelContext)
        persistedFavorites = service.fetchBooks() ?? []
        
        // Sincronizamos el estado de los corazones con la lista general en memoria
        for index in books.indices {
            let isSaved = persistedFavorites.contains { $0.title == books[index].title }
            books[index].isFavorite = isSaved
        }
    }
}

#Preview {
    FavoriteListView(books: .constant([Book.bookTest]))
        .modelContainer(for: Book.self, inMemory: true)
}
