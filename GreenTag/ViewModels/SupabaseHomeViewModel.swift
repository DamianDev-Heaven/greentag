//
//  HomeViewModel.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var featuredProducts: [Product] = []
    @Published var recentProducts: [Product] = []
    @Published var donations: [Product] = []
    @Published var categoryStats: [String: Int] = [:]
    
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var loadingState: LoadingState = .idle
    
    // Filters and search
    @Published var searchText = ""
    @Published var selectedCategory: ProductCategory?
    @Published var selectedFilter: ProductFilter = .all
    @Published var selectedSort: ProductSort = .newest
    @Published var showDonationsOnly = false
    
    // Pagination
    @Published var hasMoreContent = true
    private var currentOffset = 0
    private let pageSize = AppConstants.Business.Pagination.defaultPageSize
    
    private let productService = SupabaseProductService.shared
    private let authService = SupabaseAuthService.shared
    
    init() {
        loadInitialData()
        setupRealTimeSubscriptions()
    }
    
    // MARK: - Data Loading Methods
    
    func loadInitialData() async {
        isLoading = true
        loadingState = .loading
        errorMessage = nil
        
        do {
            async let featuredProductsTask = productService.getFeaturedProducts(limit: 10)
            async let recentProductsTask = productService.getRecentProducts(limit: 10)
            async let donationsTask = productService.getDonations(limit: 10)
            async let categoryStatsTask = productService.getCategoryStats()
            
            let (featured, recent, donations, stats) = try await (
                featuredProductsTask,
                recentProductsTask,
                donationsTask,
                categoryStatsTask
            )
            
            self.featuredProducts = featured
            self.recentProducts = recent
            self.donations = donations
            self.categoryStats = stats
            
            loadingState = .success
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        isRefreshing = true
        currentOffset = 0
        hasMoreContent = true
        
        await loadInitialData()
        
        isRefreshing = false
    }
    
    func loadFeaturedProducts() async {
        do {
            let products = try await productService.getFeaturedProducts(limit: 10)
            featuredProducts = products
        } catch {
            handleError(error)
        }
    }
    
    func loadRecentProducts() async {
        do {
            let products = try await productService.getRecentProducts(limit: 10)
            recentProducts = products
        } catch {
            handleError(error)
        }
    }
    
    func loadDonations() async {
        do {
            let products = try await productService.getDonations(limit: 10)
            donations = products
        } catch {
            handleError(error)
        }
    }
    
    func loadMoreProducts() async {
        guard hasMoreContent && !isLoading else { return }
        
        do {
            let newProducts = try await productService.getProducts(
                limit: pageSize,
                offset: currentOffset + pageSize,
                category: selectedCategory,
                isDonation: showDonationsOnly ? true : nil,
                searchQuery: searchText.isEmpty ? nil : searchText,
                sortBy: selectedSort
            )
            
            if newProducts.count < pageSize {
                hasMoreContent = false
            }
            
            // Append to appropriate array based on current filter
            switch selectedFilter {
            case .all:
                recentProducts.append(contentsOf: newProducts)
            case .donations:
                donations.append(contentsOf: newProducts)
            case .forSale:
                recentProducts.append(contentsOf: newProducts.filter { !$0.isDonation })
            case .available:
                recentProducts.append(contentsOf: newProducts.filter { $0.isAvailable })
            case .recent:
                recentProducts.append(contentsOf: newProducts)
            }
            
            currentOffset += pageSize
            
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Search and Filter Methods
    
    func searchProducts() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await refreshData()
            return
        }
        
        isLoading = true
        currentOffset = 0
        hasMoreContent = true
        
        do {
            let searchResults = try await productService.searchProducts(
                query: searchText,
                limit: pageSize,
                offset: 0
            )
            
            recentProducts = searchResults
            featuredProducts = []
            donations = []
            
            if searchResults.count < pageSize {
                hasMoreContent = false
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func applyFilters() async {
        isLoading = true
        currentOffset = 0
        hasMoreContent = true
        
        do {
            let filteredProducts = try await productService.getProducts(
                limit: pageSize,
                offset: 0,
                category: selectedCategory,
                isDonation: getDonationFilter(),
                searchQuery: searchText.isEmpty ? nil : searchText,
                sortBy: selectedSort
            )
            
            updateProductsBasedOnFilter(filteredProducts)
            
            if filteredProducts.count < pageSize {
                hasMoreContent = false
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func clearFilters() async {
        searchText = ""
        selectedCategory = nil
        selectedFilter = .all
        selectedSort = .newest
        showDonationsOnly = false
        
        await refreshData()
    }
    
    // MARK: - Product Actions
    
    func toggleFavorite(for product: Product) async {
        guard let userId = authService.currentUser?.id else { return }
        
        do {
            _ = try await productService.toggleFavorite(productId: product.id, userId: userId)
            
            // Update UI optimistically
            updateProductFavoriteStatus(productId: product.id)
            
        } catch {
            handleError(error)
        }
    }
    
    func incrementViewCount(for product: Product) async {
        do {
            try await productService.incrementViewCount(productId: product.id)
        } catch {
            // Silently fail for view count increment
            print("Failed to increment view count: \(error)")
        }
    }
    
    // MARK: - Real-time Subscriptions
    
    private func setupRealTimeSubscriptions() {
        // Subscribe to new products
        Task {
            for await newProduct in productService.subscribeToNewProducts() {
                // Add new product to recent products if it matches current filters
                if shouldIncludeNewProduct(newProduct) {
                    recentProducts.insert(newProduct, at: 0)
                    
                    // Limit array size to prevent memory issues
                    if recentProducts.count > 50 {
                        recentProducts.removeLast()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleError(_ error: Error) {
        if let appError = error as? AppError {
            errorMessage = appError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        loadingState = .failure(errorMessage ?? "Error desconocido")
    }
    
    private func getDonationFilter() -> Bool? {
        switch selectedFilter {
        case .donations:
            return true
        case .forSale:
            return false
        default:
            return showDonationsOnly ? true : nil
        }
    }
    
    private func updateProductsBasedOnFilter(_ products: [Product]) {
        switch selectedFilter {
        case .all, .available, .recent:
            recentProducts = products
            featuredProducts = []
            donations = []
        case .donations:
            donations = products
            recentProducts = []
            featuredProducts = []
        case .forSale:
            recentProducts = products.filter { !$0.isDonation }
            featuredProducts = []
            donations = []
        }
    }
    
    private func shouldIncludeNewProduct(_ product: Product) -> Bool {
        // Check category filter
        if let selectedCategory = selectedCategory,
           product.category != selectedCategory {
            return false
        }
        
        // Check donation filter
        switch selectedFilter {
        case .donations:
            return product.isDonation
        case .forSale:
            return !product.isDonation
        default:
            if showDonationsOnly {
                return product.isDonation
            }
            return product.isAvailable
        }
    }
    
    private func updateProductFavoriteStatus(productId: String) {
        // Update in all arrays
        if let index = featuredProducts.firstIndex(where: { $0.id == productId }) {
            // Note: This would require a favorited property in Product model
            // For now, we'll just trigger a refresh
        }
        
        if let index = recentProducts.firstIndex(where: { $0.id == productId }) {
            // Note: This would require a favorited property in Product model
            // For now, we'll just trigger a refresh
        }
        
        if let index = donations.firstIndex(where: { $0.id == productId }) {
            // Note: This would require a favorited property in Product model
            // For now, we'll just trigger a refresh
        }
    }
    
    // MARK: - Computed Properties
    
    var hasAnyProducts: Bool {
        !featuredProducts.isEmpty || !recentProducts.isEmpty || !donations.isEmpty
    }
    
    var totalProductsCount: Int {
        featuredProducts.count + recentProducts.count + donations.count
    }
    
    var isSearchActive: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var hasActiveFilters: Bool {
        selectedCategory != nil || selectedFilter != .all || 
        selectedSort != .newest || showDonationsOnly
    }
    
    var displayedProducts: [Product] {
        switch selectedFilter {
        case .all, .available, .recent, .forSale:
            return recentProducts
        case .donations:
            return donations
        }
    }
    
    var categoriesWithCounts: [(ProductCategory, Int)] {
        return ProductCategory.allCases.compactMap { category in
            if let count = categoryStats[category.rawValue], count > 0 {
                return (category, count)
            }
            return nil
        }.sorted { $0.1 > $1.1 }
    }
    
    // MARK: - UserDefaults Integration
    
    func saveFilterPreferences() {
        UserDefaults.standard.set(selectedCategory?.rawValue, forKey: AppConstants.UserDefaultsKeys.selectedCategory)
        UserDefaults.standard.set(showDonationsOnly, forKey: AppConstants.UserDefaultsKeys.showDonationsOnly)
    }
    
    func loadFilterPreferences() {
        if let categoryString = UserDefaults.standard.string(forKey: AppConstants.UserDefaultsKeys.selectedCategory) {
            selectedCategory = ProductCategory(rawValue: categoryString)
        }
        showDonationsOnly = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.showDonationsOnly)
    }
}