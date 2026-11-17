//
//  BookList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI
import SwiftData

struct BookListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BookListViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                if let error = viewModel.errorMessage, viewModel.booksByCategory.isEmpty {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Reintentar") {
                            Task {
                                await viewModel.retry(modelContext: modelContext)
                            }
                        }
                        .foregroundColor(AppColors.accent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 120)
                } else {
                    LazyVStack(alignment: .leading, spacing: 34) {
                        ForEach(BookCategory.allCases) { category in
                            categorySection(category: category)
                                .task {
                                    await viewModel.loadCategoryIfNeeded(category, modelContext: modelContext)
                                }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Inicio")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadBooksIfNeeded(modelContext: modelContext)
            }
        }
    }
    
    @ViewBuilder
    private func categorySection(category: BookCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            NavigationLink(destination: CategoryDetailView(category: category)) {
                HStack(spacing: 6) {
                    Text(category.displayName)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.75))
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            
            if let categoryBooks = viewModel.books(for: category), !categoryBooks.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: 16) {
                        ForEach(categoryBooks) { book in
                            NavigationLink(destination: BookDetailView(book: book, modelContext: modelContext)) {
                                EditorialBookCard(book: book)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            } else if viewModel.isCategoryLoading(category) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(0..<3, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 165, height: 255)
                                    .overlay(
                                        ProgressView()
                                            .tint(AppColors.accent)
                                    )
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 130, height: 16)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}
