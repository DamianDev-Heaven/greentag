//
//  HomeViewModel.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var featuredProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCategory: ProductCategory? = nil
    @Published var showDonationsOnly = false
    @Published var sortOption: SortOption = .newest
    
    private let productService = ProductService()
    
    var filteredProducts: [Product] {
        var filtered = products
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                product.title.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply donation filter
        if showDonationsOnly {
            filtered = filtered.filter { $0.isDonation }
        }
        
        // Apply sorting
        return sortProducts(filtered, by: sortOption)
    }
    
    init() {
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let allProducts = try await productService.fetchProducts()
            self.products = allProducts.filter { $0.isAvailable }
            self.featuredProducts = Array(allProducts.prefix(5))
        } catch {
            self.errorMessage = "Error al cargar productos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshProducts() async {
        await loadProducts()
    }
    
    func toggleFavorite(for product: Product) async {
        // TODO: Implement favorite toggle
        do {
            try await productService.toggleFavorite(productId: product.id)
            // Update local product state if needed
        } catch {
            self.errorMessage = "Error al actualizar favorito: \(error.localizedDescription)"
        }
    }
    
    func requestProduct(_ product: Product) async {
        // TODO: Implement product request logic
        do {
            try await productService.requestProduct(productId: product.id)
            // Show success message or navigate to chat/contact
        } catch {
            self.errorMessage = "Error al solicitar producto: \(error.localizedDescription)"
        }
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        showDonationsOnly = false
        sortOption = .newest
    }
    
    private func sortProducts(_ products: [Product], by option: SortOption) -> [Product] {
        switch option {
        case .newest:
            return products.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return products.sorted { $0.createdAt < $1.createdAt }
        case .priceAscending:
            return products.sorted { 
                ($0.price ?? 0) < ($1.price ?? 0)
            }
        case .priceDescending:
            return products.sorted { 
                ($0.price ?? 0) > ($1.price ?? 0)
            }
        case .mostViewed:
            return products.sorted { $0.viewCount > $1.viewCount }
        case .mostFavorited:
            return products.sorted { $0.favoriteCount > $1.favoriteCount }
        case .distance:
            // TODO: Implement distance-based sorting when location is available
            return products
        }
    }
}

enum SortOption: String, CaseIterable {
    case newest = "newest"
    case oldest = "oldest"
    case priceAscending = "price_asc"
    case priceDescending = "price_desc"
    case mostViewed = "most_viewed"
    case mostFavorited = "most_favorited"
    case distance = "distance"
    
    var displayName: String {
        switch self {
        case .newest: return "Más recientes"
        case .oldest: return "Más antiguos"
        case .priceAscending: return "Precio: menor a mayor"
        case .priceDescending: return "Precio: mayor a menor"
        case .mostViewed: return "Más vistos"
        case .mostFavorited: return "Más favoritos"
        case .distance: return "Distancia"
        }
    }
}