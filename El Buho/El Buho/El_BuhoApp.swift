//
//  El_BuhoApp.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct El_BuhoApp: App {
    init() {
        Self.configureNavigationBarAppearance()
    }
    
    static func configureNavigationBarAppearance() {
        let inlineDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
            .withDesign(.serif)?
            .withSymbolicTraits(.traitBold)
        let inlineFont = inlineDescriptor.map { UIFont(descriptor: $0, size: 18) } ?? UIFont.boldSystemFont(ofSize: 18)
        
        let largeDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            .withDesign(.serif)?
            .withSymbolicTraits(.traitBold)
        let largeFont = largeDescriptor.map { UIFont(descriptor: $0, size: 34) } ?? UIFont.boldSystemFont(ofSize: 34)
        
        let goldColor = UIColor(AppColors.accent)
        let navyColor = UIColor(AppColors.background)
        
        // Apariencia cuando el scroll está hasta arriba (Large Title visible)
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.largeTitleTextAttributes = [
            .foregroundColor: goldColor,
            .font: largeFont
        ]
        scrollEdgeAppearance.titleTextAttributes = [
            .foregroundColor: goldColor,
            .font: inlineFont
        ]
        
        // Apariencia cuando se baja el scroll (Inline Title centrado)
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = navyColor
        standardAppearance.shadowColor = .clear
        standardAppearance.largeTitleTextAttributes = [
            .foregroundColor: goldColor,
            .font: largeFont
        ]
        standardAppearance.titleTextAttributes = [
            .foregroundColor: goldColor,
            .font: inlineFont
        ]
        
        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = standardAppearance
        navBar.compactAppearance = standardAppearance
        navBar.scrollEdgeAppearance = scrollEdgeAppearance
        navBar.compactScrollEdgeAppearance = scrollEdgeAppearance
        navBar.prefersLargeTitles = true
        navBar.tintColor = goldColor
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Inicializa la base de datos local para el modelo Book
        .modelContainer(for: Book.self)
    }
}
