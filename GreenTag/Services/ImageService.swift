//
//  ImageService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation

class ImageService {
    private let networkManager = NetworkManager.shared
    
    // MARK: - Image Upload
    
    func uploadImage(_ image: UIImage, compressionQuality: CGFloat = 0.8) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageError.compressionFailed
        }
        
        return try await uploadImageData(imageData)
    }
    
    func uploadImageData(_ imageData: Data) async throws -> String {
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate upload time
        
        // Mock implementation - return a fake URL
        let imageId = UUID().uuidString
        return "https://example.com/images/\(imageId).jpg"
        
        // Actual API call:
        // let response = try await networkManager.uploadImage(
        //     imageData: imageData,
        //     endpoint: "/images/upload"
        // )
        // let uploadResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: response)
        // return uploadResponse.imageURL
    }
    
    func uploadMultipleImages(_ images: [UIImage], compressionQuality: CGFloat = 0.8) async throws -> [String] {
        var imageURLs: [String] = []
        
        for image in images {
            let url = try await uploadImage(image, compressionQuality: compressionQuality)
            imageURLs.append(url)
        }
        
        return imageURLs
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
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    func loadImage(from url: String) async throws -> UIImage {
        // Check if image is in cache
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            return cachedImage
        }
        
        // Simulate network download
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, you would download from the URL
        // guard let imageURL = URL(string: url) else {
        //     throw ImageError.invalidURL
        // }
        // 
        // let (data, _) = try await URLSession.shared.data(from: imageURL)
        // guard let image = UIImage(data: data) else {
        //     throw ImageError.invalidImageData
        // }
        
        // For mock purposes, return a placeholder image
        guard let placeholderImage = createPlaceholderImage() else {
            throw ImageError.invalidImageData
        }
        
        // Cache the image
        imageCache.setObject(placeholderImage, forKey: url as NSString)
        
        return placeholderImage
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

// MARK: - Image Errors

enum ImageError: LocalizedError {
    case compressionFailed
    case uploadFailed
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
        case .uploadFailed:
            return "Error al subir la imagen"
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

// MARK: - Image Upload Response

struct ImageUploadResponse: Codable {
    let imageURL: String
    let thumbnailURL: String?
    let width: Int
    let height: Int
    let fileSize: Int
}