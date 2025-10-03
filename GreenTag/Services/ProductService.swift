//
//  ProductService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Firebase
import FirebaseFirestore

class ProductService {
    static let shared = ProductService()
    
    private let firebaseManager = FirebaseManager.shared
    private let authService = AuthService.shared
    
    private init() {}
    
    // MARK: - Product CRUD Operations
    
    func createProduct(_ product: Product) async throws -> Product {
        guard let userId = authService.currentUserUID else {
            throw ProductError.userNotAuthenticated
        }
        
        do {
            var newProduct = product
            newProduct.sellerId = userId
            newProduct.createdAt = Date()
            newProduct.updatedAt = Date()
            newProduct.isActive = true
            
            // Create search terms for better searchability
            newProduct.searchTerms = createSearchTerms(for: newProduct)
            
            let productId = try await firebaseManager.create(
                collection: FirebaseCollections.products,
                data: newProduct
            )
            
            newProduct.id = productId
            
            // Update user's product count
            try await updateUserProductCount(userId: userId, increment: true)
            
            return newProduct
            
        } catch {
            throw ProductError.creationFailed(error.localizedDescription)
        }
    }
    
    func getProduct(id: String) async throws -> Product {
        do {
            return try await firebaseManager.read(
                collection: FirebaseCollections.products,
                document: id,
                type: Product.self
            )
        } catch {
            throw ProductError.notFound
        }
    }
    
    func updateProduct(_ product: Product) async throws -> Product {
        guard let productId = product.id else {
            throw ProductError.invalidProduct
        }
        
        guard let userId = authService.currentUserUID else {
            throw ProductError.userNotAuthenticated
        }
        
        // Verify ownership
        let existingProduct = try await getProduct(id: productId)
        guard existingProduct.sellerId == userId else {
            throw ProductError.unauthorized
        }
        
        do {
            var updatedProduct = product
            updatedProduct.updatedAt = Date()
            updatedProduct.searchTerms = createSearchTerms(for: updatedProduct)
            
            try await firebaseManager.update(
                collection: FirebaseCollections.products,
                document: productId,
                data: updatedProduct
            )
            
            return updatedProduct
            
        } catch {
            throw ProductError.updateFailed(error.localizedDescription)
        }
    }
    
    func deleteProduct(id: String) async throws {
        guard let userId = authService.currentUserUID else {
            throw ProductError.userNotAuthenticated
        }
        
        // Verify ownership
        let product = try await getProduct(id: id)
        guard product.sellerId == userId else {
            throw ProductError.unauthorized
        }
        
        do {
            // Delete product images from storage
            for imageURL in product.images {
                if let imagePath = extractStoragePath(from: imageURL) {
                    try? await firebaseManager.deleteImage(path: imagePath)
                }
            }
            
            // Delete product document
            try await firebaseManager.delete(
                collection: FirebaseCollections.products,
                document: id
            )
            
            // Update user's product count
            try await updateUserProductCount(userId: userId, increment: false)
            
        } catch {
            throw ProductError.deletionFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Product Queries
    
    func getProducts(
        category: ProductCategory? = nil,
        location: String? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        sortBy: ProductSortOption = .newest,
        limit: Int = 20
    ) async throws -> [Product] {
        do {
            var products: [Product] = []
            
            if let category = category {
                products = try await firebaseManager.query(
                    collection: FirebaseCollections.products,
                    whereField: "category",
                    isEqualTo: category.rawValue,
                    orderBy: sortBy.firebaseField,
                    descending: sortBy.descending,
                    limit: limit,
                    type: Product.self
                )
            } else {
                products = try await firebaseManager.query(
                    collection: FirebaseCollections.products,
                    orderBy: sortBy.firebaseField,
                    descending: sortBy.descending,
                    limit: limit,
                    type: Product.self
                )
            }
            
            // Filter active products
            products = products.filter { $0.isActive == true }
            
            // Apply additional filters
            if let minPrice = minPrice {
                products = products.filter { $0.price >= minPrice }
            }
            
            if let maxPrice = maxPrice {
                products = products.filter { $0.price <= maxPrice }
            }
            
            if let location = location {
                products = products.filter { $0.location.lowercased().contains(location.lowercased()) }
            }
            
            return products
            
        } catch {
            throw ProductError.queryFailed(error.localizedDescription)
        }
    }
    
    func searchProducts(query: String, limit: Int = 20) async throws -> [Product] {
        do {
            return try await firebaseManager.searchProducts(query: query, limit: limit)
        } catch {
            throw ProductError.searchFailed(error.localizedDescription)
        }
    }
    
    func getProductsByUser(userId: String, limit: Int = 50) async throws -> [Product] {
        do {
            return try await firebaseManager.query(
                collection: FirebaseCollections.products,
                whereField: "sellerId",
                isEqualTo: userId,
                orderBy: "createdAt",
                descending: true,
                limit: limit,
                type: Product.self
            )
        } catch {
            throw ProductError.queryFailed(error.localizedDescription)
        }
    }
    
    func getFeaturedProducts(limit: Int = 10) async throws -> [Product] {
        do {
            return try await firebaseManager.query(
                collection: FirebaseCollections.products,
                whereField: "isFeatured",
                isEqualTo: true,
                orderBy: "createdAt",
                descending: true,
                limit: limit,
                type: Product.self
            )
        } catch {
            throw ProductError.queryFailed(error.localizedDescription)
        }
    }
    
    func getRecentProducts(limit: Int = 20) async throws -> [Product] {
        do {
            return try await firebaseManager.query(
                collection: FirebaseCollections.products,
                whereField: "isActive",
                isEqualTo: true,
                orderBy: "createdAt",
                descending: true,
                limit: limit,
                type: Product.self
            )
        } catch {
            throw ProductError.queryFailed(error.localizedDescription)
        }
    }
    
    func getProductsByCategory(_ category: ProductCategory, limit: Int = 20) async throws -> [Product] {
        do {
            return try await firebaseManager.query(
                collection: FirebaseCollections.products,
                whereField: "category",
                isEqualTo: category.rawValue,
                orderBy: "createdAt",
                descending: true,
                limit: limit,
                type: Product.self
            )
        } catch {
            throw ProductError.queryFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Product Interactions
    
    func toggleFavorite(productId: String) async throws {
        guard let userId = authService.currentUserUID else {
            throw ProductError.userNotAuthenticated
        }
        
        // TODO: Implement favorites collection
        // This would typically involve adding/removing from a favorites subcollection
        // or maintaining a favorites array in the user document
    }
    
    func incrementViewCount(productId: String) async throws {
        do {
            try await firebaseManager.updateFields(
                collection: FirebaseCollections.products,
                document: productId,
                fields: [
                    "viewCount": FieldValue.increment(Int64(1)),
                    "lastViewedAt": Date()
                ]
            )
        } catch {
            // Don't throw error for view count increment failures
            print("Failed to increment view count: \(error)")
        }
    }
    
    // MARK: - Image Management
    
    func uploadProductImages(productId: String, imagesData: [Data]) async throws -> [String] {
        do {
            let basePath = FirebaseStoragePaths.productImagesPath(productId: productId)
            return try await firebaseManager.uploadMultipleImages(
                imagesData: imagesData,
                basePath: basePath
            )
        } catch {
            throw ProductError.imageUploadFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createSearchTerms(for product: Product) -> [String] {
        var terms: [String] = []
        
        // Add title words
        terms.append(contentsOf: product.title.lowercased().components(separatedBy: .whitespacesAndNewlines))
        
        // Add description words
        terms.append(contentsOf: product.description.lowercased().components(separatedBy: .whitespacesAndNewlines))
        
        // Add category
        terms.append(product.category.rawValue.lowercased())
        
        // Add tags
        terms.append(contentsOf: product.tags.map { $0.lowercased() })
        
        // Add location
        terms.append(product.location.lowercased())
        
        // Remove duplicates and empty strings
        return Array(Set(terms.filter { !$0.isEmpty }))
    }
    
    private func updateUserProductCount(userId: String, increment: Bool) async throws {
        let field = increment ? 1 : -1
        try await firebaseManager.updateFields(
            collection: FirebaseCollections.users,
            document: userId,
            fields: ["totalSales": FieldValue.increment(Int64(field))]
        )
    }
    
    private func extractStoragePath(from url: String) -> String? {
        // Extract storage path from Firebase Storage URL
        // This is a simplified implementation
        guard let urlComponents = URLComponents(string: url),
              let path = urlComponents.path.components(separatedBy: "/o/").last else {
            return nil
        }
        
        return path.removingPercentEncoding
    }
}

// MARK: - Supporting Types

enum ProductSortOption: CaseIterable {
    case newest
    case oldest
    case priceLowToHigh
    case priceHighToLow
    case mostViewed
    case alphabetical
    
    var displayName: String {
        switch self {
        case .newest: return "Más recientes"
        case .oldest: return "Más antiguos"
        case .priceLowToHigh: return "Precio: menor a mayor"
        case .priceHighToLow: return "Precio: mayor a menor"
        case .mostViewed: return "Más vistos"
        case .alphabetical: return "A-Z"
        }
    }
    
    var firebaseField: String {
        switch self {
        case .newest, .oldest: return "createdAt"
        case .priceLowToHigh, .priceHighToLow: return "price"
        case .mostViewed: return "viewCount"
        case .alphabetical: return "title"
        }
    }
    
    var descending: Bool {
        switch self {
        case .newest, .priceHighToLow, .mostViewed: return true
        case .oldest, .priceLowToHigh, .alphabetical: return false
        }
    }
}

enum ProductError: LocalizedError {
    case userNotAuthenticated
    case invalidProduct
    case unauthorized
    case notFound
    case creationFailed(String)
    case updateFailed(String)
    case deletionFailed(String)
    case queryFailed(String)
    case searchFailed(String)
    case imageUploadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Usuario no autenticado"
        case .invalidProduct:
            return "Producto inválido"
        case .unauthorized:
            return "No tienes permisos para esta acción"
        case .notFound:
            return "Producto no encontrado"
        case .creationFailed(let message):
            return "Error al crear producto: \(message)"
        case .updateFailed(let message):
            return "Error al actualizar producto: \(message)"
        case .deletionFailed(let message):
            return "Error al eliminar producto: \(message)"
        case .queryFailed(let message):
            return "Error al consultar productos: \(message)"
        case .searchFailed(let message):
            return "Error en la búsqueda: \(message)"
        case .imageUploadFailed(let message):
            return "Error al subir imágenes: \(message)"
        case .unauthorizedAccess:
            return "No tienes permisos para esta acción"
        case .unknownError:
            return "Ha ocurrido un error inesperado"
        }
    }
}