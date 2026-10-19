//
//  listalibro.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI

struct listaLibro: View {
    
    let libros = ["Libro 1", "Libro 2", "Libro 3", "Libro 4", "Libro 5", "Libro 6", "Libro 7", "Libro 8", "Libro 9"]
    
    let columnas = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Colores.fondoPrincipal.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columnas, spacing: 20) {
                        ForEach(libros, id: \.self) { libro in
                            NavigationLink(destination: DetalleLibroView(titulo: libro)) {
                                LibroCelda(titulo: libro)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Lista libros")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InicioView_Previews: PreviewProvider {
    static var previews: some View {
        listaLibro()
    }
}
