//
//  ImageService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseStorage

class ImageService: ObservableObject {
    static let shared = ImageService()
    
    private let firebaseManager = FirebaseManager.shared
    private let storage = Storage.storage()
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {
        setupCache()
    }
    
    private func setupCache() {
        imageCache.countLimit = 100
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Image Upload
    
    func uploadImage(_ image: UIImage, path: String, compressionQuality: CGFloat = 0.8) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageError.compressionFailed
        }
        
        return try await uploadImageData(imageData, path: path)
    }
    
    func uploadImageData(_ imageData: Data, path: String) async throws -> String {
        do {
            return try await firebaseManager.uploadImage(
                data: imageData,
                path: path,
                contentType: "image/jpeg"
            )
        } catch {
            throw ImageError.uploadFailed(error.localizedDescription)
        }
    }
    
    func uploadMultipleImages(_ images: [UIImage], basePath: String, compressionQuality: CGFloat = 0.8) async throws -> [String] {
        var imageURLs: [String] = []
        
        for (index, image) in images.enumerated() {
            let imagePath = "\(basePath)/image_\(index)_\(UUID().uuidString).jpg"
            let url = try await uploadImage(image, path: imagePath, compressionQuality: compressionQuality)
            imageURLs.append(url)
        }
        
        return imageURLs
    }
    
    func uploadProfileImage(_ image: UIImage, userId: String, compressionQuality: CGFloat = 0.8) async throws -> String {
        let path = FirebaseStoragePaths.userProfilePath(userId: userId) + "/profile.jpg"
        return try await uploadImage(image, path: path, compressionQuality: compressionQuality)
    }
    
    func uploadProductImages(_ images: [UIImage], productId: String, compressionQuality: CGFloat = 0.8) async throws -> [String] {
        let basePath = FirebaseStoragePaths.productImagesPath(productId: productId)
        return try await uploadMultipleImages(images, basePath: basePath, compressionQuality: compressionQuality)
    }
    
    // MARK: - Image Processing
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> UIImage {
        var compressionQuality: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        let maxSizeBytes = maxSizeKB * 1024
        
        while let data = imageData, data.count > maxSizeBytes && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = image.jpegData(compressionQuality: compressionQuality)
        }
        
        guard let finalData = imageData,
              let compressedImage = UIImage(data: finalData) else {
            return image
        }
        
        return compressedImage
    }
    
    func createThumbnail(_ image: UIImage, size: CGSize = CGSize(width: 150, height: 150)) -> UIImage {
        return resizeImage(image, targetSize: size)
    }
    
    // MARK: - Image Download and Caching
    
    func loadImage(from url: String) async throws -> UIImage {
        // Check if image is in cache
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            return cachedImage
        }
        
        do {
            let imageData = try await firebaseManager.downloadImage(url: url)
            guard let image = UIImage(data: imageData) else {
                throw ImageError.invalidImageData
            }
            
            // Cache the image
            imageCache.setObject(image, forKey: url as NSString)
            return image
            
        } catch {
            throw ImageError.downloadFailed(error.localizedDescription)
        }
    }
    
    func preloadImages(urls: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    try? await self.loadImage(from: url)
                }
            }
        }
    }
    
    func clearImageCache() {
        imageCache.removeAllObjects()
    }
    
    // MARK: - Image Deletion
    
    func deleteImage(path: String) async throws {
        do {
            try await firebaseManager.deleteImage(path: path)
        } catch {
            throw ImageError.deletionFailed(error.localizedDescription)
        }
    }
    
    func deleteImages(paths: [String]) async throws {
        for path in paths {
            try await deleteImage(path: path)
        }
    }
    
    // MARK: - Utility Methods
    
    private func createPlaceholderImage(size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Create a simple gradient placeholder
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Add icon
            let iconSize: CGFloat = 60
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            
            UIColor.systemGray3.setFill()
            context.cgContext.fillEllipse(in: iconRect)
        }
    }
    
    func validateImageFormat(_ data: Data) -> Bool {
        // Check if data represents a valid image format
        guard data.count > 4 else { return false }
        
        let bytes = [UInt8](data.prefix(4))
        
        // Check for common image format headers
        // JPEG: FF D8 FF
        if bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
            return true
        }
        
        // PNG: 89 50 4E 47
        if bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
            return true
        }
        
        // WebP: 52 49 46 46
        if bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 {
            return true
        }
        
        return false
    }
    
    func getImageDimensions(from data: Data) -> CGSize? {
        guard let image = UIImage(data: data) else { return nil }
        return image.size
    }
}

// MARK: - Supporting Types

enum ImageError: LocalizedError {
    case compressionFailed
    case uploadFailed(String)
    case downloadFailed(String)
    case deletionFailed(String)
    case invalidURL
    case invalidImageData
    case fileSizeTooLarge
    case unsupportedFormat
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Error al comprimir la imagen"
        case .uploadFailed(let message):
            return "Error al subir la imagen: \(message)"
        case .downloadFailed(let message):
            return "Error al descargar la imagen: \(message)"
        case .deletionFailed(let message):
            return "Error al eliminar la imagen: \(message)"
        case .invalidURL:
            return "URL de imagen inválida"
        case .invalidImageData:
            return "Datos de imagen inválidos"
        case .fileSizeTooLarge:
            return "El archivo es demasiado grande"
        case .unsupportedFormat:
            return "Formato de imagen no soportado"
        case .networkError:
            return "Error de conexión"
        case .unknownError:
            return "Ha ocurrido un error inesperado"
        }
    }
}

struct ImageUploadResult {
    let url: String
    let path: String
    let size: Int
}
    let thumbnailURL: String?
    let width: Int
    let height: Int
    let fileSize: Int
}