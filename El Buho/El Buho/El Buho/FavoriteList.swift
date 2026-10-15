//
//  libroFavorito.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct FavoritosView: View {
    @Environment(LibroStore.self) var store
    let columnas = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colores.fondoPrincipal.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columnas, spacing: 20) {
                        ForEach(store.favoritos) { libro in
                            NavigationLink(destination: DetalleLibroView(libro: libro)) {
                                LibroCelda(titulo: libro.titulo)
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
                            .foregroundColor(Colores.acentoLujo)
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
