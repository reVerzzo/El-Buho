//
//  El_BuhoApp.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI
import SwiftData

@main
struct El_BuhoApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Inicializa la base de datos local para el modelo Book
        .modelContainer(for: Book.self)
    }
}
