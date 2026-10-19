//
//  BookList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI

struct listaLibro: View {
    
    @Environment(LibroStore.self) var store
    @State private var showProfile = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colores.background.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(store.books) { book in
                            NavigationLink(destination: DetalleLibroView(title: book)) {
                                LibroCelda(title: book.title)
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
                        showProfile = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(Colores.accent)
                    }
                }
            }

            .sheet(isPresented: $showProfile) {
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
