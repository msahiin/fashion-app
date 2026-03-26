import UIKit
import CoreImage

extension UIImage {
    /// Extracts the dominant color from the image.
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let size = CGSize(width: 50, height: 50)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(size.width)
        let bitsPerComponent = 8
        
        var bitmapData = [UInt8](repeating: 0, count: Int(size.width * size.height) * bytesPerPixel)
        guard let context = CGContext(
            data: &bitmapData,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        var redCount: Int = 0
        var greenCount: Int = 0
        var blueCount: Int = 0
        var alphaCount: Int = 0
        var validPixelCount: Int = 0
        
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let r = bitmapData[offset]
                let g = bitmapData[offset + 1]
                let b = bitmapData[offset + 2]
                let a = bitmapData[offset + 3]
                
                // Ignore mostly transparent or near white/black background noise if any
                if a > 50 {
                    redCount += Int(r)
                    greenCount += Int(g)
                    blueCount += Int(b)
                    alphaCount += Int(a)
                    validPixelCount += 1
                }
            }
        }
        
        guard validPixelCount > 0 else { return nil }
        
        let avgRed = CGFloat(redCount) / CGFloat(validPixelCount) / 255.0
        let avgGreen = CGFloat(greenCount) / CGFloat(validPixelCount) / 255.0
        let avgBlue = CGFloat(blueCount) / CGFloat(validPixelCount) / 255.0
        let avgAlpha = CGFloat(alphaCount) / CGFloat(validPixelCount) / 255.0
        
        return UIColor(red: avgRed, green: avgGreen, blue: avgBlue, alpha: avgAlpha)
    }
    
    /// Finds the closest hex color from a predefined list.
    func closestPresetHexColor(from presets: [(name: String, hex: String)]) -> String? {
        guard let dominantColor = self.dominantColor(),
              let dominantComponents = dominantColor.cgColor.components,
              dominantComponents.count >= 3 else {
            return nil
        }
        
        let dR = dominantComponents[0]
        let dG = dominantComponents[1]
        let dB = dominantComponents[2]
        
        var minDistance: CGFloat = .infinity
        var closestHex: String? = nil
        
        for preset in presets {
            let presetColor = UIColor(hex: preset.hex)
            guard let pComponents = presetColor.cgColor.components, pComponents.count >= 3 else { continue }
            
            let pR = pComponents[0]
            let pG = pComponents[1]
            let pB = pComponents[2]
            
            // Euclidean distance
            let distance = pow(dR - pR, 2) + pow(dG - pG, 2) + pow(dB - pB, 2)
            
            if distance < minDistance {
                minDistance = distance
                closestHex = preset.hex
            }
        }
        
        return closestHex
    }
}

// Ensure UIColor can be initialized from hex
extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(after: hexString.startIndex)
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
