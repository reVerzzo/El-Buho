//
//  BookDetail.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct DetalleLibroView: View {

    @Environment(LibroStore.self) var store

    var title: String
    
    var body: some View {
        ZStack {
            Colores.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(Colores.accent.opacity(0.4))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(Colores.background)
                        )
                    
                    Button(action: {
                        store.toggleFavorito(libro: book)
                    }) {
                        Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                            .font(.title)
                            .foregroundColor(Colores.contrast)
                            .padding()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Colores.accent)
                    
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(Colores.secondaryText)
                    
                    Spacer().frame(height: 20)
                    
                    Text(book.description)
                        .font(.headline)
                        .foregroundColor(Colores.primaryText)
                    
                    Text("Este es un libro fascinante lleno de misterio y sabiduría. La interfaz ha sido diseñada utilizando el paradigma declarativo de SwiftUI, aplicando Stacks, Spacers y Modifiers para lograr un layout flexible y adaptable.")
                        .font(.body)
                        .foregroundColor(Colores.primaryText)
                }
                .padding()
                
                Spacer()
            }
        }
        .tint(Colores.accent)
    }
}

struct DetalleLibroView_Previews: PreviewProvider {
    static var previews: some View {
        DetalleLibroView(title: Libro(
            title: "El Secreto del Búho",
            author: "Autor de Prueba",
            description: "Prueba.",
            isFavorite: false
        ))
        .environment(LibroStore())
    }
}
