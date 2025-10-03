//
//  ProfileViewModel.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var userProducts: [Product] = []
    @Published var userReviews: [Review] = []
    @Published var userShipments: [Shipment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab: ProfileTab = .products
    
    private let userService = UserService()
    private let productService = ProductService()
    
    func loadUserProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        async let userTask = userService.fetchUser(by: userId)
        async let productsTask = productService.fetchUserProducts(userId: userId)
        async let reviewsTask = userService.fetchUserReviews(userId: userId)
        async let shipmentsTask = userService.fetchUserShipments(userId: userId)
        
        do {
            let (user, products, reviews, shipments) = try await (
                userTask, productsTask, reviewsTask, shipmentsTask
            )
            
            self.currentUser = user
            self.userProducts = products
            self.userReviews = reviews
            self.userShipments = shipments
            
        } catch {
            self.errorMessage = "Error al cargar perfil: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateProfile(_ user: User) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedUser = try await userService.updateUser(user)
            self.currentUser = updatedUser
            
            // Update locally stored user data
            if let userData = try? JSONEncoder().encode(updatedUser) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
            
        } catch {
            self.errorMessage = "Error al actualizar perfil: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteProduct(_ product: Product) async {
        do {
            try await productService.deleteProduct(productId: product.id)
            userProducts.removeAll { $0.id == product.id }
        } catch {
            self.errorMessage = "Error al eliminar producto: \(error.localizedDescription)"
        }
    }
    
    func refreshProfile() async {
        guard let userId = currentUser?.id else { return }
        await loadUserProfile(userId: userId)
    }
    
    var averageRatingString: String {
        guard let user = currentUser else { return "0.0" }
        return String(format: "%.1f", user.averageRating)
    }
    
    var totalProductsCount: Int {
        userProducts.count
    }
    
    var activeProductsCount: Int {
        userProducts.filter { $0.isAvailable }.count
    }
    
    var soldProductsCount: Int {
        userProducts.filter { !$0.isAvailable }.count
    }
    
    var donationsCount: Int {
        userProducts.filter { $0.isDonation }.count
    }
    
    var salesCount: Int {
        userProducts.filter { !$0.isDonation }.count
    }
    
    var memberSinceString: String {
        guard let user = currentUser else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: user.memberSince)
    }
}

enum ProfileTab: String, CaseIterable {
    case products = "products"
    case reviews = "reviews"
    case shipments = "shipments"
    case stats = "stats"
    
    var displayName: String {
        switch self {
        case .products: return "Productos"
        case .reviews: return "Reseñas"
        case .shipments: return "Envíos"
        case .stats: return "Estadísticas"
        }
    }
    
    var icon: String {
        switch self {
        case .products: return "square.grid.2x2"
        case .reviews: return "star.fill"
        case .shipments: return "shippingbox"
        case .stats: return "chart.bar.fill"
        }
    }
}