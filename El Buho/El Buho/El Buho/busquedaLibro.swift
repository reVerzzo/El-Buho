//
//  busquedaLibro.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct BusquedaView: View {
    
    @State private var textoBusqueda: String = ""
    
    let librosRecientes = ["Libro 1", "Libro 2", "Libro 3", "Libro 4"]
    let columnas = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Colores.fondoPrincipal.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
                    TextField("Buscar...", text: $textoBusqueda)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(Colores.textoPrincipal)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("Recientes:")
                        .font(.headline)
                        .foregroundColor(Colores.textoPrincipal)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ScrollView {
                        LazyVGrid(columns: columnas, spacing: 20) {
                            ForEach(librosRecientes, id: \.self) { libro in
                                NavigationLink(destination: DetalleLibroView(titulo: libro)) {
                                    
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Búsqueda")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BusquedaView_Previews: PreviewProvider {
    static var previews: some View {
        BusquedaView()
    }
}
