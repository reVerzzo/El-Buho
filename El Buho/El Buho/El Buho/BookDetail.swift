//
//  detalleLibro.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct DetalleLibroView: View {

    @Environment(LibroStore.self) var store

    var titulo: String
    
    var body: some View {
        ZStack {
            Colores.fondoPrincipal.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(Colores.acentoLujo.opacity(0.4))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(Colores.fondoPrincipal)
                        )
                    
                    Button(action: {
                        store.toggleFavorito(libro: libro)
                    }) {
                        Image(systemName: libro.isFavorito ? "heart.fill" : "heart")
                            .font(.title)
                            .foregroundColor(Colores.contraste)
                            .padding()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(libro.titulo)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Colores.acentoLujo)
                    
                    Text(libro.autor)
                        .font(.subheadline)
                        .foregroundColor(Colores.textoSecundario)
                    
                    Spacer().frame(height: 20)
                    
                    Text(libro.descripcion)
                        .font(.headline)
                        .foregroundColor(Colores.textoPrincipal)
                    
                    Text("Este es un libro fascinante lleno de misterio y sabiduría. La interfaz ha sido diseñada utilizando el paradigma declarativo de SwiftUI, aplicando Stacks, Spacers y Modifiers para lograr un layout flexible y adaptable.")
                        .font(.body)
                        .foregroundColor(Colores.textoPrincipal)
                }
                .padding()
                
                Spacer()
            }
        }
        .tint(Colores.acentoLujo)
    }
}

struct DetalleLibroView_Previews: PreviewProvider {
    static var previews: some View {
        DetalleLibroView(libro: Libro(
            titulo: "El Secreto del Búho",
            autor: "Autor de Prueba",
            descripcion: "Prueba.",
            isFavorito: false
        ))
        .environment(LibroStore()
    }
}
