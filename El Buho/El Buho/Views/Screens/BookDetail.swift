//
//  BookDetail.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI
import SwiftData
import UIKit

struct BookDetailView: View {
    @State private var viewModel: BookDetailViewModel
    
    init(book: Book, modelContext: ModelContext) {
        _viewModel = State(initialValue: BookDetailViewModel(book: book, modelContext: modelContext))
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Rectangle()
                                .fill(AppColors.accent.opacity(0.2))
                                .frame(height: 280)
                            
                            if let coverURL = viewModel.book.largeCoverURL ?? viewModel.book.coverURL {
                                AsyncImage(url: coverURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .tint(AppColors.accent)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 240)
                                            .cornerRadius(10)
                                            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
                                    case .failure:
                                        Image(systemName: "book.closed")
                                            .font(.system(size: 60))
                                            .foregroundColor(AppColors.accent)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppColors.accent)
                            }
                        }
                        
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                viewModel.toggleFavoritePersistence()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.65))
                                    .background(.ultraThinMaterial, in: Circle())
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 3)
                                
                                Image(systemName: viewModel.book.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(
                                        viewModel.book.isFavorite
                                            ? Color(red: 1.0, green: 0.23, blue: 0.19)
                                            : Color.white
                                    )
                                    .shadow(
                                        color: viewModel.book.isFavorite
                                            ? Color(red: 1.0, green: 0.23, blue: 0.19).opacity(0.5)
                                            : .clear,
                                        radius: 4,
                                        x: 0,
                                        y: 1
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(16)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.book.title)
                            .font(.title)
                            .bold()
                            .foregroundColor(AppColors.accent)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(viewModel.book.author)
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Spacer().frame(height: 16)
                        
                        Text("Descripción")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        if viewModel.isLoadingDescription {
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.12))
                                    .frame(height: 14)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.12))
                                    .frame(height: 14)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 220, height: 14)
                            }
                            .padding(.top, 4)
                        } else {
                            Text(viewModel.book.synopsis)
                                .font(.body)
                                .foregroundColor(AppColors.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.accent)
        .task {
            await viewModel.loadDescriptionIfNeeded()
        }
    }
}