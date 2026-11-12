//
//  BookDetail.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI
import SwiftData

struct BookDetailView: View {
    @State private var viewModel: BookDetailViewModel
    
    init(book: Book, modelContext: ModelContext) {
        _viewModel = State(initialValue: BookDetailViewModel(book: book, modelContext: modelContext))
    }
    
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
                        viewModel.toggleFavoritePersistence()
                    }) {
                        Image(systemName: viewModel.book.isFavorite ? "heart.fill" : "heart")
                            .font(.title)
                            .foregroundColor(AppColors.contrast)
                            .padding()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.book.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(AppColors.accent)
                    
                    Text(viewModel.book.author)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer().frame(height: 20)
                    
                    Text("Descripción")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(viewModel.book.synopsis)
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