//
//  BookCell.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI

struct BookCell: View {
    let title: String
    
    var body: some View {
        VStack {
        
            Rectangle()
                .fill(AppColors.accent.opacity(0.8))
                .frame(height: 140)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: "book.closed")
                        .foregroundColor(AppColors.background)
                        .font(.title)
                )
            
           
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(1) 
        }
    }
}

struct BookCell_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            BookCell(title: "Libro de Prueba")
        }
    }
}
