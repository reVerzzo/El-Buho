//
//  FavoriteList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import SwiftUI
import SwiftData
import UIKit

struct FavoriteListView: View {
    @Binding var books: [Book]
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: FavoriteListViewModel?
    @State private var draggedBook: DraggedBookSnapshot? = nil
    @State private var dragLocation: CGPoint = .zero
    @State private var trashFrame: CGRect = .zero
    @State private var isHoveringTrash: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                if let viewModel = viewModel {
                    if viewModel.persistedFavorites.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.accent.opacity(0.7))
                            Text("Aún no tienes libros favoritos")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            Text("Toca el corazón en cualquier libro para guardarlo aquí.")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        BookGrid(
                            books: Bindable(viewModel).persistedFavorites,
                            isEditing: viewModel.isEditing,
                            selectedBookIDs: viewModel.selectedBookIDs,
                            onSelectBook: { book in
                                viewModel.toggleSelection(for: book)
                            },
                            draggedBookID: draggedBook?.id,
                            onDragChanged: { snapshot, location in
                                if draggedBook == nil {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        draggedBook = snapshot
                                    }
                                }
                                if location != .zero {
                                    dragLocation = location
                                    let hovering = trashFrame.insetBy(dx: -24, dy: -24).contains(location)
                                    if hovering != isHoveringTrash {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            isHoveringTrash = hovering
                                        }
                                        if hovering {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                }
                            },
                            onDragEnded: { snapshot, location in
                                let shouldDelete = trashFrame.insetBy(dx: -24, dy: -24).contains(location) || isHoveringTrash
                                // 1. Limpiamos primero todo el estado de arrastre antes de eliminar el libro
                                draggedBook = nil
                                dragLocation = .zero
                                isHoveringTrash = false
                                
                                // 2. Ejecutamos la eliminación en el MainActor de forma segura
                                if shouldDelete {
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                    Task { @MainActor in
                                        viewModel.removeFavorite(
                                            id: snapshot.id,
                                            title: snapshot.title,
                                            globalBooks: $books
                                        )
                                    }
                                }
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 100)
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .overlay {
                if let draggedBook {
                    ZStack {
                        if dragLocation != .zero {
                            BookCell(
                                title: draggedBook.title,
                                coverURL: draggedBook.coverURL
                            )
                            .frame(width: 100)
                            .scaleEffect(isHoveringTrash ? 0.75 : 1.05)
                            .opacity(0.9)
                            .shadow(color: .black.opacity(0.5), radius: 10, y: 5)
                            .position(dragLocation)
                            .allowsHitTesting(false)
                        }
                        
                        VStack {
                            Spacer()
                            trashDropZone
                                .padding(.bottom, 16)
                        }
                        .allowsHitTesting(false)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .coordinateSpace(name: "FavoriteArea")
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if let viewModel = viewModel, !viewModel.persistedFavorites.isEmpty {
                    if viewModel.isEditing {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(role: .destructive) {
                                viewModel.removeSelectedFavorites(globalBooks: $books)
                            } label: {
                                Label("Quitar (\(viewModel.selectedBookIDs.count))", systemImage: "trash")
                                    .foregroundColor(viewModel.selectedBookIDs.isEmpty ? AppColors.secondaryText : .red)
                            }
                            .disabled(viewModel.selectedBookIDs.isEmpty)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.toggleEditing()
                        }) {
                            if viewModel.isEditing {
                                Text("Listo")
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.accent)
                            } else {
                                Image(systemName: "pencil")
                                    .foregroundColor(AppColors.accent)
                            }
                        }
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
    
    private var trashDropZone: some View {
        VStack(spacing: 6) {
            Image(systemName: isHoveringTrash ? "trash.fill" : "trash")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(isHoveringTrash ? Color.red : AppColors.contrast.opacity(0.95))
                        .shadow(color: (isHoveringTrash ? Color.red : Color.black).opacity(0.5), radius: 12)
                )
                .scaleEffect(isHoveringTrash ? 1.2 : 1.0)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                trashFrame = geometry.frame(in: .named("FavoriteArea"))
                            }
                            .onChange(of: geometry.frame(in: .named("FavoriteArea"))) { _, newFrame in
                                trashFrame = newFrame
                            }
                    }
                )
            
            Text(isHoveringTrash ? "Suelta para quitar" : "Arrastra aquí")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.black.opacity(0.6)))
        }
    }
}
