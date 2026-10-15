//
//  listalibro.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI

struct listaLibro: View {
    
    @Environment(LibroStore.self) var store
    @State private var mostrarPerfil = false
    
    let columnas = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colores.fondoPrincipal.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columnas, spacing: 20) {
                        ForEach(store.libros) { libro in
                            NavigationLink(destination: DetalleLibroView(libro: libro)) {
                                LibroCelda(titulo: libro.titulo)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Lista libros")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarPerfil = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(Colores.acentoLujo)
                    }
                }
            }

            .sheet(isPresented: $mostrarPerfil) {
                PerfilView() 
            }
        }
    }
}

struct InicioView_Previews: PreviewProvider {
    static var previews: some View {
        listaLibro().environment(LibroStore())
    }
}
