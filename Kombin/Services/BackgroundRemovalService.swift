import Foundation
import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

/// Background removal service supporting multiple providers
/// Free: On-device Vision framework (iOS 17+)
/// Premium: remove.bg API for higher quality
class BackgroundRemovalService {
    static let shared = BackgroundRemovalService()
    
    /// remove.bg API key — set this in your app settings or env
    private var apiKey: String {
        // Read from UserDefaults or environment
        UserDefaults.standard.string(forKey: "removeBgApiKey") ?? ""
    }
    
    enum RemovalQuality {
        case free       // On-device VNGenerateForegroundInstanceMaskRequest
        case premium    // remove.bg API
    }
    
    enum BGRemovalError: Error, LocalizedError {
        case noImageData
        case apiKeyMissing
        case networkError(String)
        case processingFailed
        case unsupportedOS
        
        var errorDescription: String? {
            switch self {
            case .noImageData: return "Image data is missing"
            case .apiKeyMissing: return "API key not configured"
            case .networkError(let msg): return "Network error: \(msg)"
            case .processingFailed: return "Processing failed"
            case .unsupportedOS: return "iOS 17+ required for on-device removal"
            }
        }
    }
    
    // MARK: - Public API
    
    /// Remove background from image data
    func removeBackground(
        from imageData: Data,
        quality: RemovalQuality = .free
    ) async throws -> Data {
        switch quality {
        case .free:
            return try await removeBackgroundOnDevice(imageData)
        case .premium:
            return try await removeBackgroundAPI(imageData)
        }
    }
    
    // MARK: - On-Device (Free) — Vision Framework
    
    private func removeBackgroundOnDevice(_ imageData: Data) async throws -> Data {
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            throw BGRemovalError.noImageData
        }
        
        // Use Vision's subject lifting (iOS 17+)
        if #available(iOS 17.0, *) {
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let result = try self.applySubjectLifting(cgImage: cgImage, size: uiImage.size)
                        if let pngData = result.pngData() {
                            continuation.resume(returning: pngData)
                        } else {
                            continuation.resume(throwing: BGRemovalError.processingFailed)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        } else {
            throw BGRemovalError.unsupportedOS
        }
    }
    
    @available(iOS 17.0, *)
    private func applySubjectLifting(cgImage: CGImage, size: CGSize) throws -> UIImage {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        
        guard let result = request.results?.first else {
            throw BGRemovalError.processingFailed
        }
        
        let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
        
        let ciImage = CIImage(cgImage: cgImage)
        let maskCI = CIImage(cvPixelBuffer: mask)
        
        let filter = CIFilter.blendWithMask()
        filter.inputImage = ciImage
        filter.maskImage = maskCI
        filter.backgroundImage = CIImage(color: .clear).cropped(to: ciImage.extent)
        
        guard let output = filter.outputImage else {
            throw BGRemovalError.processingFailed
        }
        
        let context = CIContext()
        guard let finalCG = context.createCGImage(output, from: output.extent) else {
            throw BGRemovalError.processingFailed
        }
        
        return UIImage(cgImage: finalCG)
    }
    
    // MARK: - remove.bg API (Premium)
    
    private func removeBackgroundAPI(_ imageData: Data) async throws -> Data {
        guard !apiKey.isEmpty else {
            throw BGRemovalError.apiKeyMissing
        }
        
        let url = URL(string: "https://api.remove.bg/v1.0/removebg")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Image file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image_file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Size parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"size\"\r\n\r\n".data(using: .utf8)!)
        body.append("auto\r\n".data(using: .utf8)!)
        
        // Format
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"format\"\r\n\r\n".data(using: .utf8)!)
        body.append("png\r\n".data(using: .utf8)!)
        
        // Type hint
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: .utf8)!)
        body.append("product\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BGRemovalError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode == 200 {
            return data
        } else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw BGRemovalError.networkError("Status \(httpResponse.statusCode): \(errorMsg)")
        }
    }
}
