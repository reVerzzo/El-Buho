//
//  ContentView.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct ContentView: View {
    @State private var books = [
        Book(title: "Libro 1"),
        Book(title: "Libro 2"),
        Book(title: "Libro 3"),
        Book(title: "Libro 4")
    ]

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
