//
//  BookList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI
import SwiftData

struct BookListView: View {
    @Binding var books: [Book]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BookListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Cargando catálogo...")
                        .tint(AppColors.accent)
                        .foregroundColor(AppColors.primaryText)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Reintentar") {
                            Task {
                                await viewModel.loadBooksIfNeeded(modelContext: modelContext) { nuevos in
                                    books = nuevos
                                }
                            }
                        }
                        .foregroundColor(AppColors.accent)
                    }
                } else {
                    ScrollView {
                        BookGrid(books: $books, indices: Array(books.indices))
                            .padding()
                    }
                }
            }
            .navigationTitle("Lista libros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleProfilePresentation()
                    }) {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .sheet(isPresented: Bindable(viewModel).isProfilePresented) {
                ProfileView()
            }
            .task {
                await viewModel.loadBooksIfNeeded(modelContext: modelContext) { nuevos in
                    books = nuevos
                }
            }
        }
    }
}