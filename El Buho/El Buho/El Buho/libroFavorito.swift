//
//  libroFavorito.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct FavoritosView: View {
    let librosFavoritos = ["Libro 1", "Libro 2", "Libro 3"]
    let columnas = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Colores.fondoPrincipal.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columnas, spacing: 20) {
                        ForEach(librosFavoritos, id: \.self) { libro in
                            NavigationLink(destination: DetalleLibroView(titulo: libro)) {
                                
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.inline)
         
            .navigationBarItems(trailing: Button(action: {
             
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(Colores.acentoLujo)
            })
        }
    }
}

struct FavoritosView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritosView()
    }
}
