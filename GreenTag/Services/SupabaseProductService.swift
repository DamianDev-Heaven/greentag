//
//  ProductService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Supabase

class ProductService {
    static let shared = ProductService()
    
    private let supabaseManager = SupabaseManager.shared
    
    private init() {}
    
    // MARK: - Product CRUD Operations
    
    func createProduct(_ product: Product) async throws -> Product {
        do {
            let response: Product = try await supabaseManager.client
                .from("products")
                .insert(product)
                .select()
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al crear producto: \(error.localizedDescription)")
        }
    }
    
    func getProduct(id: String) async throws -> Product {
        do {
            let response: Product = try await supabaseManager.client
                .from("products")
                .select("""
                    *,
                    seller:profiles!seller_id(*),
                    images:product_images(*)
                """)
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener producto: \(error.localizedDescription)")
        }
    }
    
    func updateProduct(_ product: Product) async throws -> Product {
        do {
            let response: Product = try await supabaseManager.client
                .from("products")
                .update(product)
                .eq("id", value: product.id)
                .select()
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al actualizar producto: \(error.localizedDescription)")
        }
    }
    
    func deleteProduct(id: String) async throws {
        do {
            try await supabaseManager.client
                .from("products")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            throw AppError.database("Error al eliminar producto: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Product Listing and Search
    
    func getProducts(
        limit: Int = 20,
        offset: Int = 0,
        category: ProductCategory? = nil,
        isDonation: Bool? = nil,
        isAvailable: Bool = true,
        searchQuery: String? = nil,
        sortBy: ProductSort = .newest
    ) async throws -> [Product] {
        do {
            var query = supabaseManager.client
                .from("products")
                .select("""
                    *,
                    seller:profiles!seller_id(*),
                    images:product_images(*)
                """)
                .eq("is_available", value: isAvailable)
                .range(from: offset, to: offset + limit - 1)
            
            // Apply filters
            if let category = category {
                query = query.eq("category", value: category.rawValue)
            }
            
            if let isDonation = isDonation {
                query = query.eq("is_donation", value: isDonation)
            }
            
            if let searchQuery = searchQuery, !searchQuery.isEmpty {
                query = query.textSearch("title", query: searchQuery)
            }
            
            // Apply sorting
            switch sortBy {
            case .newest:
                query = query.order("created_at", ascending: false)
            case .oldest:
                query = query.order("created_at", ascending: true)
            case .priceAsc:
                query = query.order("price", ascending: true)
            case .priceDesc:
                query = query.order("price", ascending: false)
            case .rating:
                query = query.order("view_count", ascending: false) // Placeholder for rating
            case .distance:
                // TODO: Implement geolocation-based sorting
                query = query.order("created_at", ascending: false)
            }
            
            let response: [Product] = try await query.execute().value
            return response
            
        } catch {
            throw AppError.database("Error al obtener productos: \(error.localizedDescription)")
        }
    }
    
    func getUserProducts(userId: String, limit: Int = 20, offset: Int = 0) async throws -> [Product] {
        do {
            let response: [Product] = try await supabaseManager.client
                .from("products")
                .select("""
                    *,
                    seller:profiles!seller_id(*),
                    images:product_images(*)
                """)
                .eq("seller_id", value: userId)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener productos del usuario: \(error.localizedDescription)")
        }
    }
    
    func getFeaturedProducts(limit: Int = 10) async throws -> [Product] {
        do {
            let response: [Product] = try await supabaseManager.client
                .from("products")
                .select("""
                    *,
                    seller:profiles!seller_id(*),
                    images:product_images(*)
                """)
                .eq("is_available", value: true)
                .order("view_count", ascending: false)
                .limit(limit)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener productos destacados: \(error.localizedDescription)")
        }
    }
    
    func getRecentProducts(limit: Int = 10) async throws -> [Product] {
        do {
            let response: [Product] = try await supabaseManager.client
                .from("products")
                .select("""
                    *,
                    seller:profiles!seller_id(*),
                    images:product_images(*)
                """)
                .eq("is_available", value: true)
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener productos recientes: \(error.localizedDescription)")
        }
    }
    
    func getDonations(limit: Int = 20, offset: Int = 0) async throws -> [Product] {
        do {
            let response: [Product] = try await supabaseManager.client
                .from("products")
                .select("""
                    *,
                    seller:profiles!seller_id(*),
                    images:product_images(*)
                """)
                .eq("is_donation", value: true)
                .eq("is_available", value: true)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener donaciones: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Product Images
    
    func addProductImage(_ image: ProductImage) async throws -> ProductImage {
        do {
            let response: ProductImage = try await supabaseManager.client
                .from("product_images")
                .insert(image)
                .select()
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al agregar imagen: \(error.localizedDescription)")
        }
    }
    
    func getProductImages(productId: String) async throws -> [ProductImage] {
        do {
            let response: [ProductImage] = try await supabaseManager.client
                .from("product_images")
                .select()
                .eq("product_id", value: productId)
                .order("display_order", ascending: true)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener imágenes: \(error.localizedDescription)")
        }
    }
    
    func deleteProductImage(imageId: String) async throws {
        do {
            try await supabaseManager.client
                .from("product_images")
                .delete()
                .eq("id", value: imageId)
                .execute()
        } catch {
            throw AppError.database("Error al eliminar imagen: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Product Stats and Interactions
    
    func incrementViewCount(productId: String) async throws {
        do {
            try await supabaseManager.client
                .rpc("increment_view_count", params: ["product_id": productId])
                .execute()
        } catch {
            throw AppError.database("Error al incrementar vistas: \(error.localizedDescription)")
        }
    }
    
    func toggleFavorite(productId: String, userId: String) async throws -> Bool {
        do {
            // Check if already favorited
            let existing: [String: Any] = try await supabaseManager.client
                .from("favorites")
                .select("*")
                .eq("product_id", value: productId)
                .eq("user_id", value: userId)
                .execute()
                .value
            
            if existing.isEmpty {
                // Add to favorites
                try await supabaseManager.client
                    .from("favorites")
                    .insert(["product_id": productId, "user_id": userId])
                    .execute()
                return true
            } else {
                // Remove from favorites
                try await supabaseManager.client
                    .from("favorites")
                    .delete()
                    .eq("product_id", value: productId)
                    .eq("user_id", value: userId)
                    .execute()
                return false
            }
        } catch {
            throw AppError.database("Error al manejar favorito: \(error.localizedDescription)")
        }
    }
    
    func getUserFavorites(userId: String, limit: Int = 20, offset: Int = 0) async throws -> [Product] {
        do {
            let response: [Product] = try await supabaseManager.client
                .from("favorites")
                .select("""
                    product:products(
                        *,
                        seller:profiles!seller_id(*),
                        images:product_images(*)
                    )
                """)
                .eq("user_id", value: userId)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener favoritos: \(error.localizedDescription)")
        }
    }
    
    func isProductFavorited(productId: String, userId: String) async throws -> Bool {
        do {
            let response: [String: Any] = try await supabaseManager.client
                .from("favorites")
                .select("id")
                .eq("product_id", value: productId)
                .eq("user_id", value: userId)
                .execute()
                .value
            
            return !response.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Product Categories and Stats
    
    func getCategoryStats() async throws -> [String: Int] {
        do {
            let response: [String: Any] = try await supabaseManager.client
                .rpc("get_category_stats")
                .execute()
                .value
            
            return response as? [String: Int] ?? [:]
        } catch {
            throw AppError.database("Error al obtener estadísticas de categorías: \(error.localizedDescription)")
        }
    }
    
    func searchProducts(query: String, limit: Int = 20, offset: Int = 0) async throws -> [Product] {
        do {
            let response: [Product] = try await supabaseManager.client
                .from("products")
                .select("""
                    *,
                    seller:profiles!seller_id(*),
                    images:product_images(*)
                """)
                .textSearch("title,description", query: query)
                .eq("is_available", value: true)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error en búsqueda: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Real-time Subscriptions
    
    func subscribeToProductUpdates(productId: String) -> AsyncStream<Product> {
        return AsyncStream { continuation in
            let channel = supabaseManager.client.realtime.channel("products")
            
            Task {
                await channel
                    .on("postgres_changes", filter: ChannelFilter(
                        event: "UPDATE",
                        schema: "public",
                        table: "products",
                        filter: "id=eq.\(productId)"
                    )) { payload in
                        if let product = try? JSONDecoder().decode(Product.self, from: JSONSerialization.data(withJSONObject: payload.new)) {
                            continuation.yield(product)
                        }
                    }
                    .subscribe()
            }
            
            continuation.onTermination = { _ in
                Task {
                    await channel.unsubscribe()
                }
            }
        }
    }
    
    func subscribeToNewProducts() -> AsyncStream<Product> {
        return AsyncStream { continuation in
            let channel = supabaseManager.client.realtime.channel("new-products")
            
            Task {
                await channel
                    .on("postgres_changes", filter: ChannelFilter(
                        event: "INSERT",
                        schema: "public", 
                        table: "products"
                    )) { payload in
                        if let product = try? JSONDecoder().decode(Product.self, from: JSONSerialization.data(withJSONObject: payload.new)) {
                            continuation.yield(product)
                        }
                    }
                    .subscribe()
            }
            
            continuation.onTermination = { _ in
                Task {
                    await channel.unsubscribe()
                }
            }
        }
    }
}