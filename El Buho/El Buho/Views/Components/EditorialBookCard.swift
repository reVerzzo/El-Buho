import SwiftUI

struct EditorialBookCard: View {
    let book: Book
    var useCarouselWidth: Bool = true
    
    var body: some View {
        if useCarouselWidth {
            cardContent
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * 0.44
                }
        } else {
            cardContent
                .frame(maxWidth: .infinity)
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Color.clear
                .frame(height: 255)
                .frame(maxWidth: .infinity)
                .overlay {
                    CachedCoverImage(url: book.coverURL, contentMode: .fill) {
                        placeholderCover
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
            
            Text(book.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .topLeading)
        }
    }
    
    private var placeholderCover: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(AppColors.accent.opacity(0.75))
            .overlay(
                Image(systemName: "book.closed")
                    .font(.largeTitle)
                    .foregroundColor(AppColors.background)
            )
    }
}
