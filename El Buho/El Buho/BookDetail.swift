//
//  BookDetail.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Binding var book: Book
    
    // Obtenemos el contexto de SwiftData como en el ContentView del profesor
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(AppColors.accent.opacity(0.4))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.background)
                        )
                    
                    Button(action: {
                        toggleFavoritePersistence()
                    }) {
                        Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                            .font(.title)
                            .foregroundColor(AppColors.contrast)
                            .padding()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(AppColors.accent)
                    
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer().frame(height: 20)
                    
                    Text("Descripción")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(book.synopsis)
                        .font(.body)
                        .foregroundColor(AppColors.primaryText)
                }
                .padding()
                
                Spacer()
            }
        }
        .tint(AppColors.accent)
    }
    
    // Función que conecta el botón con el BookService del profesor
    private func toggleFavoritePersistence() {
        let service = BookService(context: modelContext)
        book.isFavorite.toggle()
        
        if book.isFavorite {
            // Si no existe ya en la base de datos, lo guardamos
            if service.searchBook(title: book.title)?.isEmpty ?? true {
                service.saveBook(book: book)
            }
        } else {
            // Si se quita de favoritos, lo buscamos en SwiftData y lo eliminamos
            if let savedBooks = service.searchBook(title: book.title) {
                for savedBook in savedBooks {
                    service.removeBook(book: savedBook)
                }
            }
        }
    }
}
