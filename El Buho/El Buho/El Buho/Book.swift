import Foundation

struct Book: Identifiable {
    let id = UUID()
    let title: String
    var author = ""
    var description = ""
    var isFavorite = false
}