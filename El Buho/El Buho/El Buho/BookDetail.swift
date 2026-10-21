//
//  BookDetail.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct BookDetailView: View {

    @Binding var book: Book
    
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
                        book.isFavorite.toggle()
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
                    
                    if !book.author.isEmpty {
                        Text(book.author)
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    if !book.description.isEmpty {
                        Text(book.description)
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    Text("Este es un libro fascinante lleno de misterio y sabiduría. La interfaz ha sido diseñada utilizando el paradigma declarativo de SwiftUI, aplicando Stacks, Spacers y Modifiers para lograr un layout flexible y adaptable.")
                        .font(.body)
                        .foregroundColor(AppColors.primaryText)
                }
                .padding()
                
                Spacer()
            }
        }
        .tint(AppColors.accent)
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(book: .constant(Book(
            title: "El Secreto del Búho",
            author: "Autor de Prueba",
            description: "Prueba.",
            isFavorite: false
        )))
    }
}
