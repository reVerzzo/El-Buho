//
//  FavoriteList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI
import SwiftData

struct FavoriteListView: View {
    @Binding var books: [Book]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: FavoriteListViewModel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    if let viewModel = viewModel {
                         BookGrid(
                            // Enlazamos directamente a la propiedad del ViewModel
                            books: Bindable(viewModel).persistedFavorites,
                            indices: Array(viewModel.persistedFavorites.indices)
                        )
                        .padding()
                    } else {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .onAppear {
                if viewModel == nil {
                     viewModel = FavoriteListViewModel(modelContext: modelContext)
                }
                viewModel?.loadFavoritesFromDatabase(globalBooks: $books)
            }
        }
    }
}
