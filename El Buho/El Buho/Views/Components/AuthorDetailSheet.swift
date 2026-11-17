import SwiftUI

struct AuthorDetailSheet: View {
    let authorDetail: AuthorDetail?
    let isLoading: Bool
    let fallbackName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    authorAvatar
                        .padding(.top, 12)
                    
                    VStack(spacing: 6) {
                        Text(authorDetail?.name ?? fallbackName)
                            .font(.system(.title2, design: .serif).bold())
                            .foregroundColor(AppColors.accent)
                            .multilineTextAlignment(.center)
                        
                        if let personalName = authorDetail?.personalName,
                           !personalName.isEmpty,
                           personalName.caseInsensitiveCompare(authorDetail?.name ?? fallbackName) != .orderedSame {
                            Text(personalName)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    if let lifespan = formattedLifespan {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(AppColors.accent)
                            Text(lifespan)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppColors.primaryText)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Biografía")
                            .font(.headline)
                            .foregroundColor(AppColors.accent)
                        
                        if isLoading {
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.12))
                                    .frame(height: 14)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.12))
                                    .frame(height: 14)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 200, height: 14)
                            }
                            .padding(.top, 4)
                        } else if let bio = authorDetail?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .foregroundColor(AppColors.primaryText)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("Biografía no disponible en OpenLibrary")
                                .font(.body)
                                .italic()
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    private var authorAvatar: some View {
        if let photoURL = authorDetail?.photoURL {
            CachedCoverImage(url: photoURL, contentMode: .fill) {
                fallbackAvatar
            }
            .frame(width: 110, height: 110)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppColors.accent.opacity(0.6), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
        } else {
            fallbackAvatar
        }
    }
    
    private var fallbackAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 110, height: 110)
                .overlay(
                    Circle()
                        .stroke(AppColors.accent.opacity(0.4), lineWidth: 1.5)
                )
            
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColors.accent.opacity(0.85))
        }
    }
    
    private var formattedLifespan: String? {
        let birth = authorDetail?.birthDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        let death = authorDetail?.deathDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let birth, !birth.isEmpty {
            if let death, !death.isEmpty {
                return "\(birth) – \(death)"
            } else {
                return "\(birth) – Presente"
            }
        } else if let death, !death.isEmpty {
            return "Fallecido: \(death)"
        }
        return nil
    }
}
