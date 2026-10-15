//
//  libroCelda.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI

struct LibroCelda: View {
    var titulo: String
    
    var body: some View {
        VStack {
        
            Rectangle()
                .fill(Colores.acentoLujo.opacity(0.8))
                .frame(height: 140)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: "book.closed")
                        .foregroundColor(Colores.fondoPrincipal)
                        .font(.title)
                )
            
           
            Text(titulo)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Colores.textoPrincipal)
                .lineLimit(1) 
        }
    }
}

struct LibroCelda_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Colores.fondoPrincipal.ignoresSafeArea()
            LibroCelda(titulo: "Libro de Prueba")
        }
    }
}
