//
//  busquedaLibro.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct SearchView: View {
    
    @State private var searchText: String = ""
    
    let recentBooks = ["Libro 1", "Libro 2", "Libro 3", "Libro 4"]
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.primaryBackground.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
                    TextField("Buscar...", text: $searchText)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(Colors.primaryText)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("Recientes:")
                        .font(.headline)
                        .foregroundColor(Colors.primaryText)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(recentBooks, id: \.self) { book in
                                NavigationLink(destination: BookDetailView(title: book)) {
                                    
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
