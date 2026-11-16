//
//  SearchBook.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI
import SwiftData

struct SearchBookView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = BookSearcher()
    @State private var selectedBookForDetail: Book? = nil
    
    private var isSearchEmpty: Bool {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.secondaryText)
                        
                        TextField("Buscar...", text: $viewModel.searchText)
                            .foregroundColor(AppColors.primaryText)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                            .onSubmit {
                                viewModel.performSearch()
                            }
                        
                        if !viewModel.searchText.isEmpty {
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.clearSearch()
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .onChange(of: viewModel.searchText) { _, newValue in
                        viewModel.handleSearchTextChange(newValue)
                    }
                    
                    if isSearchEmpty {
                        recentSearchesSection
                    } else {
                        activeSearchSection
                    }
                }
                .padding(.bottom, 100)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Búsqueda")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedBookForDetail) { book in
                BookDetailView(book: book, modelContext: modelContext)
            }
        }
    }
    
    @ViewBuilder
    private var recentSearchesSection: some View {
        HStack {
            Text("Búsquedas recientes")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
            
            if !viewModel.recentBooks.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.clearRecentBooks()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Borrar historial")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColors.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        
        if viewModel.recentBooks.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 36))
                    .foregroundColor(AppColors.secondaryText.opacity(0.6))
                Text("No hay búsquedas recientes.")
                    .foregroundColor(AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
        } else {
            @Bindable var bindableViewModel = viewModel
            BookGrid(
                books: $bindableViewModel.recentBooks,
                onTapBook: { tappedBook in
                    viewModel.recordRecentBook(tappedBook)
                    selectedBookForDetail = tappedBook
                }
            )
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private var activeSearchSection: some View {
        Text("Resultados:")
            .font(.headline)
            .foregroundColor(AppColors.primaryText)
            .padding(.horizontal, 16)
        
        if viewModel.isLoading {
            HStack {
                Spacer()
                ProgressView("Descargando libros...")
                    .tint(AppColors.accent)
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            .padding(.top, 80)
        } else if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 16) {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    viewModel.performSearch()
                }) {
                    Text("Reintentar")
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.background)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppColors.accent)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
        } else if viewModel.searchResults.isEmpty {
            HStack {
                Spacer()
                Text("No se encontraron resultados.")
                    .foregroundColor(AppColors.secondaryText)
                Spacer()
            }
            .padding(.top, 80)
        } else {
            @Bindable var bindableViewModel = viewModel
            BookGrid(
                books: $bindableViewModel.searchResults,
                onTapBook: { tappedBook in
                    viewModel.recordRecentBook(tappedBook)
                    selectedBookForDetail = tappedBook
                }
            )
            .padding(.horizontal, 16)
        }
    }
}

struct SearchBookView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBookView()
    }
}
