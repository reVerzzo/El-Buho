import SwiftUI
import UIKit
import CryptoKit

enum ImageCacheManager {
    nonisolated(unsafe) private static let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 400
        cache.totalCostLimit = 90 * 1024 * 1024
        return cache
    }()
    
    nonisolated private static let diskCacheDirectory: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("ElBuhoCoverCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()
    
    nonisolated private static let imageSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 8
        config.timeoutIntervalForRequest = 10
        config.urlCache = URLCache(
            memoryCapacity: 60 * 1024 * 1024,
            diskCapacity: 250 * 1024 * 1024
        )
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
    
    nonisolated private static func diskFileURL(for url: URL) -> URL {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let filename = digest.map { String(format: "%02x", $0) }.joined() + ".jpg"
        return diskCacheDirectory.appendingPathComponent(filename)
    }
    
    nonisolated static func cachedImage(for url: URL) -> UIImage? {
        let key = url.absoluteString as NSString
        if let mem = memoryCache.object(forKey: key) {
            return mem
        }
        let fileURL = diskFileURL(for: url)
        if let data = try? Data(contentsOf: fileURL),
           let diskImage = UIImage(data: data) {
            memoryCache.setObject(diskImage, forKey: key, cost: data.count)
            return diskImage
        }
        return nil
    }
    
    nonisolated static func loadImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }
        
        let fileURL = diskFileURL(for: url)
        if let data = try? Data(contentsOf: fileURL),
           let diskImage = UIImage(data: data) {
            let prepared = await diskImage.byPreparingForDisplay() ?? diskImage
            memoryCache.setObject(prepared, forKey: key, cost: data.count)
            return prepared
        }
        
        do {
            let (data, response) = try await imageSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let image = UIImage(data: data) else {
                return nil
            }
            try? data.write(to: fileURL, options: .atomic)
            let prepared = await image.byPreparingForDisplay() ?? image
            memoryCache.setObject(prepared, forKey: key, cost: data.count)
            return prepared
        } catch {
            return nil
        }
    }
}

struct CachedCoverImage<Placeholder: View>: View {
    let url: URL?
    var fallbackURL: URL? = nil
    var contentMode: ContentMode = .fill
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var loadedImage: UIImage? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            if let image = loadedImage ?? immediateCachedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                placeholder()
                    .opacity(0.35)
                ProgressView()
                    .tint(AppColors.accent)
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await fetchIfNeeded()
        }
    }
    
    private var immediateCachedImage: UIImage? {
        if let url, let cached = ImageCacheManager.cachedImage(for: url) {
            return cached
        }
        if let fallbackURL, let cachedFallback = ImageCacheManager.cachedImage(for: fallbackURL) {
            return cachedFallback
        }
        return nil
    }
    
    private func fetchIfNeeded() async {
        guard let url else { return }
        if let cached = ImageCacheManager.cachedImage(for: url) {
            loadedImage = cached
            return
        }
        if let fallbackURL, let cachedFallback = ImageCacheManager.cachedImage(for: fallbackURL) {
            loadedImage = cachedFallback
        } else {
            isLoading = true
        }
        if let downloaded = await ImageCacheManager.loadImage(from: url) {
            loadedImage = downloaded
        }
        isLoading = false
    }
}
