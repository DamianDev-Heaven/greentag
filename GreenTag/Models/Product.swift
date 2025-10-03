//
//  Product.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let category: ProductCategory
    let imageURLs: [String]
    let sellerId: String
    let sellerName: String
    let sellerRating: Double
    let location: Location
    let price: Double?
    let isDonation: Bool
    let isAvailable: Bool
    let condition: ProductCondition
    let createdAt: Date
    let updatedAt: Date
    let tags: [String]
    let viewCount: Int
    let favoriteCount: Int
    
    var formattedPrice: String {
        if isDonation {
            return "Gratis"
        } else if let price = price {
            return String(format: "%.2f €", price)
        } else {
            return "Precio a consultar"
        }
    }
    
    var primaryImageURL: String? {
        imageURLs.first
    }
    
    var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        category: ProductCategory,
        imageURLs: [String],
        sellerId: String,
        sellerName: String,
        sellerRating: Double,
        location: Location,
        price: Double? = nil,
        isDonation: Bool = false,
        isAvailable: Bool = true,
        condition: ProductCondition = .good,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        viewCount: Int = 0,
        favoriteCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.imageURLs = imageURLs
        self.sellerId = sellerId
        self.sellerName = sellerName
        self.sellerRating = sellerRating
        self.location = location
        self.price = price
        self.isDonation = isDonation
        self.isAvailable = isAvailable
        self.condition = condition
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.viewCount = viewCount
        self.favoriteCount = favoriteCount
    }
}

enum ProductCategory: String, CaseIterable, Codable {
    case electronics = "electronics"
    case clothing = "clothing"
    case furniture = "furniture"
    case books = "books"
    case toys = "toys"
    case kitchen = "kitchen"
    case sports = "sports"
    case garden = "garden"
    case decoration = "decoration"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .electronics: return "Electrónicos"
        case .clothing: return "Ropa"
        case .furniture: return "Muebles"
        case .books: return "Libros"
        case .toys: return "Juguetes"
        case .kitchen: return "Cocina"
        case .sports: return "Deportes"
        case .garden: return "Jardín"
        case .decoration: return "Decoración"
        case .other: return "Otros"
        }
    }
    
    var icon: String {
        switch self {
        case .electronics: return "iphone"
        case .clothing: return "tshirt"
        case .furniture: return "bed.double"
        case .books: return "book"
        case .toys: return "gamecontroller"
        case .kitchen: return "fork.knife"
        case .sports: return "sportscourt"
        case .garden: return "leaf"
        case .decoration: return "paintbrush"
        case .other: return "cube.box"
        }
    }
}

enum ProductCondition: String, CaseIterable, Codable {
    case new = "new"
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    
    var displayName: String {
        switch self {
        case .new: return "Nuevo"
        case .excellent: return "Excelente"
        case .good: return "Bueno"
        case .fair: return "Regular"
        case .poor: return "Malo"
        }
    }
}

struct Location: Codable, Hashable {
    let address: String
    let city: String
    let country: String
    let latitude: Double?
    let longitude: Double?
    
    var displayAddress: String {
        "\(city), \(country)"
    }
}

// MARK: - Sample Data
extension Product {
    static let sampleProducts: [Product] = [
        Product(
            title: "iPhone 12 Pro",
            description: "iPhone 12 Pro en excelente estado, sin rayones, con caja original y cargador. Perfecto para alguien que quiera un teléfono de calidad a buen precio.",
            category: .electronics,
            imageURLs: ["https://example.com/iphone1.jpg", "https://example.com/iphone2.jpg"],
            sellerId: "user1",
            sellerName: "Ana García",
            sellerRating: 4.8,
            location: Location(address: "Calle Mayor 123", city: "Madrid", country: "España", latitude: 40.4168, longitude: -3.7038),
            price: 650.00,
            condition: .excellent,
            tags: ["Apple", "smartphone", "iOS"],
            viewCount: 45,
            favoriteCount: 12
        ),
        Product(
            title: "Libros de cocina vegana",
            description: "Colección de 5 libros de cocina vegana en muy buen estado. Perfectos para quien quiera iniciarse en la cocina plant-based.",
            category: .books,
            imageURLs: ["https://example.com/books1.jpg"],
            sellerId: "user2",
            sellerName: "Carlos Rodríguez",
            sellerRating: 4.6,
            location: Location(address: "Paseo de Gracia 456", city: "Barcelona", country: "España", latitude: 41.3851, longitude: 2.1734),
            isDonation: true,
            condition: .good,
            tags: ["cocina", "vegano", "recetas"],
            viewCount: 23,
            favoriteCount: 8
        )
    ]
}