import SwiftUI

/// Reusable cached image view that avoids re-decoding Data→UIImage on every redraw
struct CachedImageView: View {
    let imageData: Data?
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    
    @State private var cachedImage: UIImage?
    
    init(imageData: Data?, contentMode: ContentMode = .fit, cornerRadius: CGFloat = 0) {
        self.imageData = imageData
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let uiImage = cachedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Image(systemName: "tshirt")
                    .font(.system(size: 24, weight: .ultraLight))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onAppear { decodeImage() }
        .onChange(of: imageData) { _, _ in decodeImage() }
    }
    
    private func decodeImage() {
        guard let data = imageData, cachedImage == nil || imageData != nil else { return }
        // Decode on background thread to avoid UI stutter
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                cachedImage = image
            }
        }
    }
}

/// In-memory image cache for frequently accessed thumbnails
actor ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func store(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    /// Get or decode image from data, caching result
    func cachedImage(for key: String, data: Data) -> UIImage? {
        if let cached = cache.object(forKey: key as NSString) {
            return cached
        }
        
        guard let image = UIImage(data: data) else { return nil }
        
        // Store a thumbnail for grid views (max 200px)
        let thumbnailSize = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        let thumbnail = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        }
        
        cache.setObject(thumbnail, forKey: key as NSString)
        return thumbnail
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
