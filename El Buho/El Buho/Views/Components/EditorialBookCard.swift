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
                    coverView
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
    
    @ViewBuilder
    private var coverView: some View {
        if let coverURL = book.coverURL {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.accent.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .tint(AppColors.accent)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderCover
                @unknown default:
                    placeholderCover
                }
            }
        } else {
            placeholderCover
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
