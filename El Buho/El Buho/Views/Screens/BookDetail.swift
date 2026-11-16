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
    @State private var selectedCoverIndex: Int = 0
    
    private let secondaryCardColor = Color(red: 18/255, green: 38/255, blue: 68/255)
    
    init(book: Book, modelContext: ModelContext) {
        _viewModel = State(initialValue: BookDetailViewModel(book: book, modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                coversCarouselHeader
                
                VStack(spacing: 14) {
                    titleAndAuthorHeader
                    ratingsRow
                    metadataCardsRow
                    
                    if viewModel.book.canReadOnline, viewModel.book.readerURL != nil {
                        readNowButton
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                
                synopsisSection
                    .padding(.horizontal, 16)
                
                if let publishers = uniquePublishers, !publishers.isEmpty {
                    publishersSection(publishers: publishers)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 100)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.accent)
        .sheet(isPresented: $viewModel.isAuthorSheetPresented) {
            AuthorDetailSheet(
                authorDetail: viewModel.authorDetail,
                isLoading: viewModel.isLoadingAuthor,
                fallbackName: viewModel.book.author
            )
        }
        .fullScreenCover(isPresented: $viewModel.isReaderPresented) {
            if let readerURL = viewModel.book.readerURL {
                SafariReaderView(url: readerURL)
                    .ignoresSafeArea()
            }
        }
        .task {
            await viewModel.loadDescriptionIfNeeded()
        }
    }
    
    // MARK: - 1. Carrusel de Portadas + Botón Favorito
    private var coversCarouselHeader: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                LinearGradient(
                    colors: [
                        secondaryCardColor,
                        AppColors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320)
                
                if viewModel.coverURLs.isEmpty {
                    placeholderCover
                        .frame(width: 180, height: 260)
                } else {
                    TabView(selection: $selectedCoverIndex) {
                        ForEach(Array(viewModel.coverURLs.enumerated()), id: \.offset) { index, url in
                            ZStack {
                                CachedCoverImage(
                                    url: url,
                                    contentMode: .fit
                                ) {
                                    placeholderCover
                                        .frame(width: 180, height: 255)
                                }
                                .frame(height: 255)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 6)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.bottom, 22)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(height: 320)
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
    }
    
    private var placeholderCover: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(secondaryCardColor)
            .overlay(
                Image(systemName: "book.closed")
                    .font(.system(size: 56))
                    .foregroundColor(AppColors.accent)
            )
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
    }
    
    // MARK: - 2. Título, Subtítulo y Autor Interactivo
    private var titleAndAuthorHeader: some View {
        VStack(spacing: 8) {
            Text(viewModel.book.title)
                .font(.system(.title, design: .serif).bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if let subtitle = viewModel.book.subtitle, !subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(subtitle)
                    .font(.headline)
                    .italic()
                    .foregroundColor(Color(white: 0.78))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Button {
                viewModel.openAuthorSheet()
            } label: {
                HStack(spacing: 6) {
                    Text(viewModel.book.author)
                        .font(.subheadline.weight(.semibold))
                        .underline()
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                }
                .foregroundColor(AppColors.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(AppColors.accent.opacity(0.14))
                        .overlay(
                            Capsule()
                                .stroke(AppColors.accent.opacity(0.4), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 3. Calificación con Estrellas
    private var ratingsRow: some View {
        HStack(spacing: 8) {
            if let avg = viewModel.book.ratingsAverage, avg > 0 {
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: starSymbol(for: index, rating: avg))
                            .font(.subheadline)
                            .foregroundColor(AppColors.accent)
                    }
                }
                
                Text(String(format: "%.1f / 5.0", avg))
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)
                
                if let count = viewModel.book.ratingsCount, count > 0 {
                    Text("(\(count.formatted()) calificaciones)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            } else {
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { _ in
                        Image(systemName: "star")
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText.opacity(0.5))
                    }
                }
                Text("Sin calificaciones aún")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func starSymbol(for position: Int, rating: Double) -> String {
        let threshold = Double(position)
        if rating >= threshold - 0.2 {
            return "star.fill"
        } else if rating >= threshold - 0.75 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
    
    // MARK: - 4. Fila de Metadatos Rápidos
    private var metadataCardsRow: some View {
        HStack(spacing: 10) {
            metadataCard(
                title: "Publicación",
                icon: "calendar",
                value: viewModel.book.firstPublishYear.map(String.init) ?? "N/D",
                valueColor: .white
            )
            
            metadataCard(
                title: "Extensión",
                icon: "book.pages",
                value: viewModel.book.numberOfPages.map { "\($0) págs." } ?? "N/D",
                valueColor: .white
            )
            
            metadataCard(
                title: "Disponibilidad",
                icon: viewModel.book.isPubliclyReadable ? "lock.open.fill" : "lock.fill",
                value: viewModel.book.isPubliclyReadable ? "Público\n(Lectura libre)" : "Privado\n(Con derechos)",
                valueColor: viewModel.book.isPubliclyReadable
                    ? Color(red: 0.3, green: 0.85, blue: 0.45)
                    : Color(red: 0.95, green: 0.72, blue: 0.3)
            )
        }
    }
    
    private func metadataCard(title: String, icon: String, value: String, valueColor: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption2.weight(.medium))
            }
            .foregroundColor(AppColors.secondaryText)
            
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundColor(valueColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, minHeight: 68)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(secondaryCardColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 5. Botón de Lectura Directa
    private var readNowButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            viewModel.isReaderPresented = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "book.fill")
                    .font(.headline)
                Text("Leer libro ahora")
                    .font(.headline.weight(.bold))
            }
            .foregroundColor(AppColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.accent)
                    .shadow(color: AppColors.accent.opacity(0.35), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 6. Sinopsis / Descripción
    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Descripción")
                .font(.title3.bold())
                .foregroundColor(AppColors.accent)
            
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
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(secondaryCardColor.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 7. Lista de Editoriales
    private var uniquePublishers: [String]? {
        guard let raw = viewModel.book.publishers, !raw.isEmpty else { return nil }
        var seen = Set<String>()
        var result: [String] = []
        for item in raw {
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let key = trimmed.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                result.append(trimmed)
            }
            if result.count >= 12 { break }
        }
        return result.isEmpty ? nil : result
    }
    
    private func publishersSection(publishers: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Editoriales que lo han publicado")
                .font(.headline)
                .foregroundColor(AppColors.accent)
            
            PublisherFlowLayout(spacing: 8) {
                ForEach(publishers, id: \.self) { publisher in
                    Text(publisher)
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColors.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(secondaryCardColor)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PublisherFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX)
        }
        
        return CGSize(width: min(totalWidth, maxWidth), height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}
