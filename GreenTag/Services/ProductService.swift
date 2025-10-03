//
//  ProductService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

class ProductService {
    private let networkManager = NetworkManager.shared
    
    // MARK: - Product CRUD Operations
    
    func fetchProducts() async throws -> [Product] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // For now, return mock data. Replace with actual API call
        return Product.sampleProducts
        
        // Actual API call would look like:
        // let response = try await networkManager.request(
        //     endpoint: "/products",
        //     method: .GET
        // )
        // return try JSONDecoder().decode([Product].self, from: response)
    }
    
    func fetchProduct(by id: String) async throws -> Product {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Mock implementation
        if let product = Product.sampleProducts.first(where: { $0.id == id }) {
            return product
        }
        
        throw ProductError.productNotFound
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/products/\(id)",
        //     method: .GET
        // )
        // return try JSONDecoder().decode(Product.self, from: response)
    }
    
    func createProduct(_ product: Product) async throws {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock implementation - in real app, encode product and send to API
        // let encoder = JSONEncoder()
        // let productData = try encoder.encode(product)
        // 
        // let _ = try await networkManager.request(
        //     endpoint: "/products",
        //     method: .POST,
        //     body: productData
        // )
        
        print("Product created successfully: \(product.title)")
    }
    
    func updateProduct(_ product: Product) async throws -> Product {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock implementation
        return product
        
        // Actual API call:
        // let encoder = JSONEncoder()
        // let productData = try encoder.encode(product)
        // 
        // let response = try await networkManager.request(
        //     endpoint: "/products/\(product.id)",
        //     method: .PUT,
        //     body: productData
        // )
        // return try JSONDecoder().decode(Product.self, from: response)
    }
    
    func deleteProduct(productId: String) async throws {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Mock implementation
        print("Product deleted: \(productId)")
        
        // Actual API call:
        // let _ = try await networkManager.request(
        //     endpoint: "/products/\(productId)",
        //     method: .DELETE
        // )
    }
    
    // MARK: - Product Interactions
    
    func toggleFavorite(productId: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock implementation
        print("Toggled favorite for product: \(productId)")
        
        // Actual API call:
        // let _ = try await networkManager.request(
        //     endpoint: "/products/\(productId)/favorite",
        //     method: .POST
        // )
    }
    
    func requestProduct(productId: String, buyerId: String) async throws {
        let parameters = [
            "productId": productId,
            "buyerId": buyerId
        ]
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock implementation
        print("Product requested: \(productId) by buyer: \(buyerId)")
        
        // Actual API call:
        // let _ = try await networkManager.request(
        //     endpoint: "/products/\(productId)/request",
        //     method: .POST,
        //     parameters: parameters
        // )
    }
    
    func requestProduct(productId: String) async throws {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Mock implementation
        print("Product requested: \(productId)")
        
        // Actual API call:
        // let _ = try await networkManager.request(
        //     endpoint: "/products/\(productId)/request",
        //     method: .POST
        // )
    }
    
    // MARK: - Search and Filter
    
    func searchProducts(query: String, category: ProductCategory? = nil) async throws -> [Product] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Mock implementation
        var results = Product.sampleProducts
        
        if !query.isEmpty {
            results = results.filter { product in
                product.title.localizedCaseInsensitiveContains(query) ||
                product.description.localizedCaseInsensitiveContains(query)
            }
        }
        
        if let category = category {
            results = results.filter { $0.category == category }
        }
        
        return results
        
        // Actual API call:
        // var parameters: [String: Any] = ["query": query]
        // if let category = category {
        //     parameters["category"] = category.rawValue
        // }
        // 
        // let response = try await networkManager.request(
        //     endpoint: "/products/search",
        //     method: .GET,
        //     parameters: parameters
        // )
        // return try JSONDecoder().decode([Product].self, from: response)
    }
    
    func fetchUserProducts(userId: String) async throws -> [Product] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Mock implementation - return products for specific user
        return Product.sampleProducts.filter { $0.sellerId == userId }
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/users/\(userId)/products",
        //     method: .GET
        // )
        // return try JSONDecoder().decode([Product].self, from: response)
    }
    
    func fetchProductsByCategory(_ category: ProductCategory) async throws -> [Product] {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Mock implementation
        return Product.sampleProducts.filter { $0.category == category }
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/products/category/\(category.rawValue)",
        //     method: .GET
        // )
        // return try JSONDecoder().decode([Product].self, from: response)
    }
    
    func fetchFeaturedProducts() async throws -> [Product] {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Mock implementation - return first 5 products as featured
        return Array(Product.sampleProducts.prefix(5))
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/products/featured",
        //     method: .GET
        // )
        // return try JSONDecoder().decode([Product].self, from: response)
    }
}

// MARK: - Product Errors

enum ProductError: LocalizedError {
    case productNotFound
    case invalidProductData
    case uploadFailed
    case networkError
    case unauthorizedAccess
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Producto no encontrado"
        case .invalidProductData:
            return "Datos del producto inválidos"
        case .uploadFailed:
            return "Error al subir el producto"
        case .networkError:
            return "Error de conexión"
        case .unauthorizedAccess:
            return "No tienes permisos para esta acción"
        case .unknownError:
            return "Ha ocurrido un error inesperado"
        }
    }
}