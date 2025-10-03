//
//  ProductViewModel.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    @Published var selectedProduct: Product?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Add Product Form
    @Published var title = ""
    @Published var description = ""
    @Published var selectedCategory: ProductCategory = .other
    @Published var selectedImages: [UIImage] = []
    @Published var isDonation = false
    @Published var price = ""
    @Published var condition: ProductCondition = .good
    @Published var tags: [String] = []
    @Published var newTag = ""
    @Published var address = ""
    @Published var city = ""
    @Published var country = ""
    
    private let productService = ProductService()
    private let imageService = ImageService()
    
    func loadProductDetails(productId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let product = try await productService.fetchProduct(by: productId)
            self.selectedProduct = product
        } catch {
            self.errorMessage = "Error al cargar producto: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func createProduct(sellerId: String, sellerName: String, sellerRating: Double) async -> Bool {
        guard validateProductForm() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Upload images first
            var imageURLs: [String] = []
            for image in selectedImages {
                let url = try await imageService.uploadImage(image)
                imageURLs.append(url)
            }
            
            let location = Location(
                address: address,
                city: city,
                country: country,
                latitude: nil,
                longitude: nil
            )
            
            let priceValue = isDonation ? nil : Double(price)
            
            let product = Product(
                title: title,
                description: description,
                category: selectedCategory,
                imageURLs: imageURLs,
                sellerId: sellerId,
                sellerName: sellerName,
                sellerRating: sellerRating,
                location: location,
                price: priceValue,
                isDonation: isDonation,
                condition: condition,
                tags: tags
            )
            
            try await productService.createProduct(product)
            clearForm()
            isLoading = false
            return true
            
        } catch {
            self.errorMessage = "Error al crear producto: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func requestProduct(productId: String, buyerId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await productService.requestProduct(productId: productId, buyerId: buyerId)
            // Navigate to chat or show success message
        } catch {
            self.errorMessage = "Error al solicitar producto: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    func addImage(_ image: UIImage) {
        if selectedImages.count < 5 { // Limit to 5 images
            selectedImages.append(image)
        }
    }
    
    func removeImage(at index: Int) {
        if index < selectedImages.count {
            selectedImages.remove(at: index)
        }
    }
    
    private func validateProductForm() -> Bool {
        if title.isEmpty {
            errorMessage = "El título es obligatorio"
            return false
        }
        
        if description.isEmpty {
            errorMessage = "La descripción es obligatoria"
            return false
        }
        
        if selectedImages.isEmpty {
            errorMessage = "Debes agregar al menos una imagen"
            return false
        }
        
        if !isDonation && (price.isEmpty || Double(price) == nil) {
            errorMessage = "Debes introducir un precio válido"
            return false
        }
        
        if address.isEmpty || city.isEmpty || country.isEmpty {
            errorMessage = "Debes completar la ubicación"
            return false
        }
        
        return true
    }
    
    private func clearForm() {
        title = ""
        description = ""
        selectedCategory = .other
        selectedImages = []
        isDonation = false
        price = ""
        condition = .good
        tags = []
        newTag = ""
        address = ""
        city = ""
        country = ""
    }
}