import Foundation
import SwiftData

@Model
class Book: Identifiable, Equatable {
    var id: UUID
    var title: String
    var subtitle: String?
    var author: String
    var synopsis: String
    var isFavorite: Bool
    var coverURLString: String?
    var workKey: String?
    var firstPublishYear: Int?
    var coverId: Int?
    var authorKeys: [String]?
    var ratingsAverage: Double?
    var ratingsCount: Int?
    var numberOfPages: Int?
    var publishers: [String]?
    var isPublicScan: Bool?
    var ebookAccess: String?
    var iaIdentifiers: [String]?
    
    var coverURL: URL? {
        guard let coverURLString else { return nil }
        return URL(string: coverURLString)
    }
    
    var largeCoverURL: URL? {
        if let coverId, coverId > 0 {
            return URL(string: "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg")
        }
        guard let coverURLString else { return nil }
        let largeString = coverURLString.replacingOccurrences(of: "-M.jpg", with: "-L.jpg")
        return URL(string: largeString)
    }
    
    var isPubliclyReadable: Bool {
        (isPublicScan == true) || (ebookAccess == "public")
    }
    
    var canReadOnline: Bool {
        if isPubliclyReadable, let iaIdentifiers, !iaIdentifiers.isEmpty {
            return true
        }
        if ebookAccess == "borrowable", (!(iaIdentifiers?.isEmpty ?? true) || workKey != nil) {
            return true
        }
        return false
    }
    
    var readerURL: URL? {
        if let firstIA = iaIdentifiers?.first, !firstIA.isEmpty {
            return URL(string: "https://archive.org/embed/\(firstIA)")
        }
        if let workKey, !workKey.isEmpty {
            let normalized = workKey.hasPrefix("/") ? workKey : "/\(workKey)"
            return URL(string: "https://openlibrary.org\(normalized)")
        }
        return nil
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil,
        author: String = "Autor Desconocido",
        synopsis: String = "Sin descripción disponible.",
        isFavorite: Bool = false,
        coverURLString: String? = nil,
        workKey: String? = nil,
        firstPublishYear: Int? = nil,
        coverId: Int? = nil,
        authorKeys: [String]? = nil,
        ratingsAverage: Double? = nil,
        ratingsCount: Int? = nil,
        numberOfPages: Int? = nil,
        publishers: [String]? = nil,
        isPublicScan: Bool? = nil,
        ebookAccess: String? = nil,
        iaIdentifiers: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.author = author
        self.synopsis = synopsis
        self.isFavorite = isFavorite
        self.coverURLString = coverURLString
        self.workKey = workKey
        self.firstPublishYear = firstPublishYear
        self.coverId = coverId
        self.authorKeys = authorKeys
        self.ratingsAverage = ratingsAverage
        self.ratingsCount = ratingsCount
        self.numberOfPages = numberOfPages
        self.publishers = publishers
        self.isPublicScan = isPublicScan
        self.ebookAccess = ebookAccess
        self.iaIdentifiers = iaIdentifiers
    }
    
    func detachedCopy(isFavoriteOverride: Bool? = nil) -> Book {
        Book(
            id: id,
            title: title,
            subtitle: subtitle,
            author: author,
            synopsis: synopsis,
            isFavorite: isFavoriteOverride ?? isFavorite,
            coverURLString: coverURLString,
            workKey: workKey,
            firstPublishYear: firstPublishYear,
            coverId: coverId,
            authorKeys: authorKeys,
            ratingsAverage: ratingsAverage,
            ratingsCount: ratingsCount,
            numberOfPages: numberOfPages,
            publishers: publishers,
            isPublicScan: isPublicScan,
            ebookAccess: ebookAccess,
            iaIdentifiers: iaIdentifiers
        )
    }
}

extension Book {
    static let bookTest = Book(title: "Libro de prueba", author: "Autor", isFavorite: true)
}
