import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: BookCategory
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CategoryDetailViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    init(category: BookCategory) {
        self.category = category
        _viewModel = State(initialValue: CategoryDetailViewModel(category: category))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if viewModel.isLoading {
                VStack {
                    ProgressView("Cargando \(category.displayName.lowercased())...")
                        .tint(AppColors.accent)
                        .foregroundColor(AppColors.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 120)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Reintentar") {
                        Task {
                            await viewModel.retry(modelContext: modelContext)
                        }
                    }
                    .foregroundColor(AppColors.accent)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 120)
            } else {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(viewModel.books) { book in
                        NavigationLink(destination: BookDetailView(book: book, modelContext: modelContext)) {
                            EditorialBookCard(book: book, useCarouselWidth: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.large)
        .tint(AppColors.accent)
        .task {
            await viewModel.loadBooksIfNeeded(modelContext: modelContext)
        }
    }
}
