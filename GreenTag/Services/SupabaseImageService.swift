//
//  ImageService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import SwiftUI
import Supabase

class ImageService {
    static let shared = ImageService()
    
    private let supabaseManager = SupabaseManager.shared
    
    private init() {}
    
    // MARK: - Storage Buckets
    private enum StorageBucket: String {
        case profileImages = "profile-images"
        case productImages = "product-images"
        case generalImages = "general-images"
    }
    
    // MARK: - Image Upload Methods
    
    func uploadProfileImage(image: UIImage, userId: String) async throws -> String {
        let imageData = try prepareImageForUpload(image: image)
        let fileName = "profile_\(userId)_\(UUID().uuidString).jpg"
        let filePath = "\(userId)/\(fileName)"
        
        do {
            try await supabaseManager.client.storage
                .from(StorageBucket.profileImages.rawValue)
                .upload(path: filePath, file: imageData)
            
            let publicURL = try supabaseManager.client.storage
                .from(StorageBucket.profileImages.rawValue)
                .getPublicURL(path: filePath)
            
            return publicURL.absoluteString
        } catch {
            throw AppError.storage("Error al subir imagen de perfil: \(error.localizedDescription)")
        }
    }
    
    func uploadProductImage(image: UIImage, productId: String, displayOrder: Int = 0) async throws -> ProductImage {
        let imageData = try prepareImageForUpload(image: image)
        let fileName = "product_\(productId)_\(displayOrder)_\(UUID().uuidString).jpg"
        let filePath = "\(productId)/\(fileName)"
        
        do {
            try await supabaseManager.client.storage
                .from(StorageBucket.productImages.rawValue)
                .upload(path: filePath, file: imageData)
            
            let publicURL = try supabaseManager.client.storage
                .from(StorageBucket.productImages.rawValue)
                .getPublicURL(path: filePath)
            
            let productImage = ProductImage(
                productId: productId,
                imageURL: publicURL.absoluteString,
                displayOrder: displayOrder
            )
            
            // Save to database
            let savedImage: ProductImage = try await supabaseManager.client
                .from("product_images")
                .insert(productImage)
                .select()
                .single()
                .execute()
                .value
            
            return savedImage
        } catch {
            throw AppError.storage("Error al subir imagen del producto: \(error.localizedDescription)")
        }
    }
    
    func uploadMultipleProductImages(images: [UIImage], productId: String) async throws -> [ProductImage] {
        var uploadedImages: [ProductImage] = []
        
        for (index, image) in images.enumerated() {
            do {
                let productImage = try await uploadProductImage(
                    image: image,
                    productId: productId,
                    displayOrder: index
                )
                uploadedImages.append(productImage)
            } catch {
                // Continue with other images even if one fails
                print("Failed to upload image at index \(index): \(error)")
            }
        }
        
        if uploadedImages.isEmpty {
            throw AppError.storage("No se pudo subir ninguna imagen")
        }
        
        return uploadedImages
    }
    
    func uploadGeneralImage(image: UIImage, folder: String = "general") async throws -> String {
        let imageData = try prepareImageForUpload(image: image)
        let fileName = "\(folder)_\(UUID().uuidString).jpg"
        let filePath = "\(folder)/\(fileName)"
        
        do {
            try await supabaseManager.client.storage
                .from(StorageBucket.generalImages.rawValue)
                .upload(path: filePath, file: imageData)
            
            let publicURL = try supabaseManager.client.storage
                .from(StorageBucket.generalImages.rawValue)
                .getPublicURL(path: filePath)
            
            return publicURL.absoluteString
        } catch {
            throw AppError.storage("Error al subir imagen: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Image Deletion Methods
    
    func deleteProfileImage(userId: String, imageURL: String) async throws {
        let path = extractPathFromURL(imageURL, bucket: .profileImages)
        
        do {
            try await supabaseManager.client.storage
                .from(StorageBucket.profileImages.rawValue)
                .remove(paths: [path])
        } catch {
            throw AppError.storage("Error al eliminar imagen de perfil: \(error.localizedDescription)")
        }
    }
    
    func deleteProductImage(imageId: String, imageURL: String) async throws {
        let path = extractPathFromURL(imageURL, bucket: .productImages)
        
        do {
            // Delete from storage
            try await supabaseManager.client.storage
                .from(StorageBucket.productImages.rawValue)
                .remove(paths: [path])
            
            // Delete from database
            try await supabaseManager.client
                .from("product_images")
                .delete()
                .eq("id", value: imageId)
                .execute()
        } catch {
            throw AppError.storage("Error al eliminar imagen del producto: \(error.localizedDescription)")
        }
    }
    
    func deleteAllProductImages(productId: String) async throws {
        do {
            // Get all product images
            let images: [ProductImage] = try await supabaseManager.client
                .from("product_images")
                .select()
                .eq("product_id", value: productId)
                .execute()
                .value
            
            // Delete from storage
            let paths = images.compactMap { extractPathFromURL($0.imageURL, bucket: .productImages) }
            if !paths.isEmpty {
                try await supabaseManager.client.storage
                    .from(StorageBucket.productImages.rawValue)
                    .remove(paths: paths)
            }
            
            // Delete from database (should be handled by CASCADE, but ensuring cleanup)
            try await supabaseManager.client
                .from("product_images")
                .delete()
                .eq("product_id", value: productId)
                .execute()
        } catch {
            throw AppError.storage("Error al eliminar imágenes del producto: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Image Download Methods
    
    func downloadImage(from url: String) async throws -> Data {
        guard let imageURL = URL(string: url) else {
            throw AppError.storage("URL de imagen inválida")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: imageURL)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                throw AppError.network("Error al descargar imagen")
            }
            
            return data
        } catch {
            throw AppError.network("Error al descargar imagen: \(error.localizedDescription)")
        }
    }
    
    func downloadAndCacheImage(from url: String) async throws -> UIImage {
        // Check cache first
        if let cachedData = ImageCache.shared.getData(for: url),
           let cachedImage = UIImage(data: cachedData) {
            return cachedImage
        }
        
        // Download from server
        let imageData = try await downloadImage(from: url)
        
        // Cache the data
        ImageCache.shared.setData(imageData, for: url)
        
        guard let image = UIImage(data: imageData) else {
            throw AppError.storage("No se pudo crear imagen desde los datos descargados")
        }
        
        return image
    }
    
    // MARK: - Image Processing Methods
    
    private func prepareImageForUpload(image: UIImage, maxSize: CGSize = CGSize(width: 1024, height: 1024), quality: CGFloat = 0.8) throws -> Data {
        // Resize image if needed
        let resizedImage = resizeImage(image, to: maxSize)
        
        // Convert to JPEG data
        guard let imageData = resizedImage.jpegData(compressionQuality: quality) else {
            throw AppError.storage("No se pudo procesar la imagen")
        }
        
        // Check file size (max 10MB)
        let maxSizeBytes = AppConstants.Business.maxImageSizeMB * 1024 * 1024
        if imageData.count > maxSizeBytes {
            throw AppError.storage("La imagen es demasiado grande. Máximo \(AppConstants.Business.maxImageSizeMB)MB")
        }
        
        return imageData
    }
    
    private func resizeImage(_ image: UIImage, to maxSize: CGSize) -> UIImage {
        let size = image.size
        
        // Calculate new size maintaining aspect ratio
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        // If image is already smaller, return original
        if ratio >= 1 {
            return image
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Create new image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    // MARK: - Helper Methods
    
    private func extractPathFromURL(_ url: String, bucket: StorageBucket) -> String {
        // Extract path from Supabase public URL
        // Format: https://twhqxwpkuhawzsgqamqz.supabase.co/storage/v1/object/public/bucket-name/path
        guard let urlComponents = URLComponents(string: url),
              let pathComponents = urlComponents.path.components(separatedBy: "/"),
              let bucketIndex = pathComponents.firstIndex(of: bucket.rawValue) else {
            return ""
        }
        
        let pathAfterBucket = pathComponents.dropFirst(bucketIndex + 1)
        return pathAfterBucket.joined(separator: "/")
    }
    
    // MARK: - Validation Methods
    
    func validateImageFormat(_ image: UIImage) -> Bool {
        // Check if image can be converted to JPEG
        return image.jpegData(compressionQuality: 1.0) != nil
    }
    
    func validateImageSize(_ imageData: Data) -> Bool {
        let maxSizeBytes = AppConstants.Business.maxImageSizeMB * 1024 * 1024
        return imageData.count <= maxSizeBytes
    }
    
    // MARK: - Batch Operations
    
    func uploadImagesInBatch(images: [UIImage], bucket: StorageBucket, folder: String) async throws -> [String] {
        var uploadedURLs: [String] = []
        
        for (index, image) in images.enumerated() {
            do {
                let imageData = try prepareImageForUpload(image: image)
                let fileName = "\(folder)_\(index)_\(UUID().uuidString).jpg"
                let filePath = "\(folder)/\(fileName)"
                
                try await supabaseManager.client.storage
                    .from(bucket.rawValue)
                    .upload(path: filePath, file: imageData)
                
                let publicURL = try supabaseManager.client.storage
                    .from(bucket.rawValue)
                    .getPublicURL(path: filePath)
                
                uploadedURLs.append(publicURL.absoluteString)
            } catch {
                print("Failed to upload image at index \(index): \(error)")
            }
        }
        
        return uploadedURLs
    }
}

// MARK: - Image Cache

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Setup cache directory
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cacheDir.appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure memory cache
        cache.countLimit = 100 // Maximum number of images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func setData(_ data: Data, for key: String) {
        let nsData = NSData(data: data)
        cache.setObject(nsData, forKey: NSString(string: key), cost: data.count)
        
        // Also save to disk
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        try? data.write(to: fileURL)
    }
    
    func getData(for key: String) -> Data? {
        // Check memory cache first
        if let nsData = cache.object(forKey: NSString(string: key)) {
            return Data(referencing: nsData)
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        if let diskData = try? Data(contentsOf: fileURL) {
            // Add back to memory cache
            setData(diskData, for: key)
            return diskData
        }
        
        return nil
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - String Extension for MD5

extension String {
    var md5: String {
        let data = Data(self.utf8)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}