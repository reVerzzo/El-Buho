//
//  ContentView.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
    
        TabView {
            listaLibro()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
            
            BusquedaView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar")
                }
            
            FavoritosView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Mis libros")
                }
        }
       
        .tint(Colores.acentoLujo)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
