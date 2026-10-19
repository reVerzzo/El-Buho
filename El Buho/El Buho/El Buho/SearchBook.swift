//
//  SearchBook.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct BusquedaView: View {
    
    @Environment(LibroStore.self) var store

    @State private var searchText: String = ""
    
    let recentBooks = ["Libro 1", "Libro 2", "Libro 3", "Libro 4"]
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colores.background.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
                    TextField("Buscar...", text: $searchText)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(Colores.primaryText)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("Recientes:")
                        .font(.headline)
                        .foregroundColor(Colores.primaryText)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(store.recentBooks) { book in
                                NavigationLink(destination: DetalleLibroView(title: book)) {
                                    LibroCelda(title: book.title)
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
            .environment(LibroStore()) 
    }
}
