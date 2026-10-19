//
//  El_BuhoApp.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

@main
struct El_BuhoApp: App {

    @State private var bookStore = LibroStore()

    var body: some Scene {
        WindowGroup {
            ContentView().environment(bookStore)
        }
    }
}
