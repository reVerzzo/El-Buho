//
//  BookCell.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI

struct BookCell: View {
    let title: String
    var coverURL: URL? = nil
    var isEditing: Bool = false
    var isSelected: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Color.clear
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        CachedCoverImage(url: coverURL, contentMode: .fill) {
                            placeholderCover
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? AppColors.accent : Color.clear, lineWidth: 3)
                    )
                
                if isEditing {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? AppColors.accent : .white)
                        .background(
                            Circle()
                                .fill(AppColors.background.opacity(0.75))
                                .padding(2)
                        )
                        .padding(6)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .top)
        }
    }
    
    private var placeholderCover: some View {
        Rectangle()
            .fill(AppColors.accent.opacity(0.8))
            .overlay(
                Image(systemName: "book.closed")
                    .foregroundColor(AppColors.background)
                    .font(.title)
            )
    }
}
