//
//  FavoriteList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct FavoritosView: View {
    @Environment(LibroStore.self) var store
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colores.background.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(store.favorites) { book in
                            NavigationLink(destination: DetalleLibroView(title: book)) {
                                LibroCelda(title: book.title)
                            }
                        }
                    }
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
                            .foregroundColor(Colores.accent)
                    }
                }
            }
        }
    }
}

struct FavoritosView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritosView().environment(LibroStore())
    }
}
