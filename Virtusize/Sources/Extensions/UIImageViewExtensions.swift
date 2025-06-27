import UIKit
import ImageIO

extension UIImage {
    public static func animatedGif(named name: String) -> UIImage? {
        // Try main bundle first
        if let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif"),
           let imageData = try? Data(contentsOf: bundleURL) {
            return animatedGif(data: imageData)
        }
        // Fallback: try Virtusize bundle (for frameworks)
        let apiBundle = Bundle(for: Virtusize.self)
        if let bundleURL = apiBundle.url(forResource: name, withExtension: "gif"),
           let imageData = try? Data(contentsOf: bundleURL) {
            return animatedGif(data: imageData)
        }
        print("[Virtusize] GIF not found in main bundle or Virtusize bundle: \(name).gif")
        return nil
    }

    static func animatedGif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: Double = 0
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
                let gifProperties = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
                let frameDuration = (gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double) ?? (gifProperties?[kCGImagePropertyGIFDelayTime as String] as? Double) ?? 0.1
                duration += frameDuration
            }
        }
        return UIImage.animatedImage(with: images, duration: duration)
    }
}
