//
//  ContentView.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct ContentView: View {
    @State private var books: [Book] = []

    var body: some View {
        TabView {
            BookListView(books: $books)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }

            SearchBookView(books: $books)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar")
                }

            FavoriteListView(books: $books)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Mis libros")
                }
        }
        .tint(AppColors.accent)
    }
}