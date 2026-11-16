//
//  ContentView.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BookListView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }

            SearchBookView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Búsqueda")
                }

            FavoriteListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Favoritos")
                }
        }
        .tint(AppColors.accent)
    }
}
