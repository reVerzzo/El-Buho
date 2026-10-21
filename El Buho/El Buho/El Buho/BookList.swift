//
//  BookList.swift
//  El Buho
//
//  Created by Facultad de Contaduría y Administración on 28/09/26.
//

import SwiftUI

struct BookListView: View {
    @Binding var books: [Book]
    @State private var isProfilePresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    BookGrid(books: $books, indices: Array(books.indices))
                        .padding()
                }
            }
            .navigationTitle("Lista libros")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isProfilePresented = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(AppColors.accent)
                    }
                }
            }

            .sheet(isPresented: $isProfilePresented) {
                ProfileView()
            }
        }
    }
}

struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        BookListView(books: .constant([Book(title: "Libro de prueba")]))
    }
}
