//
//  SearchBook.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI

struct SearchBookView: View {
    @Binding var books: [Book]

    @State private var viewModel = SearchBookViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    
                    TextField("Buscar en OpenLibrary...", text: $viewModel.searchText)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(AppColors.primaryText)
                        .padding(.horizontal)
                        .padding(.top)
                        .onSubmit {
                            viewModel.performSearch()
                        }
                    
                    Text("Resultados:")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    if viewModel.isLoading {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView("Descargando libros...")
                                .tint(AppColors.accent)
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                        }
                        Spacer()
                        
                    } else if let errorMessage = viewModel.errorMessage {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                        
                    } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("No se encontraron resultados.")
                                .foregroundColor(AppColors.secondaryText)
                            Spacer()
                        }
                        Spacer()
                        
                    } else {
                        ScrollView {
                            @Bindable var bindableViewModel = viewModel
                            BookGrid(
                                books: $bindableViewModel.searchResults,
                                indices: Array(viewModel.searchResults.indices)
                            )
                            .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Búsqueda")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SearchBookView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBookView(books: .constant([Book.bookTest]))
    }
}