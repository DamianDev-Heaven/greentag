//
//  Enums.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

// MARK: - Product Category
enum ProductCategory: String, CaseIterable, Codable {
    case clothing = "clothing"
    case electronics = "electronics"
    case furniture = "furniture"
    case books = "books"
    case sports = "sports"
    case toys = "toys"
    case home = "home"
    case beauty = "beauty"
    case automotive = "automotive"
    case garden = "garden"
    case food = "food"
    case health = "health"
    case pets = "pets"
    case music = "music"
    case art = "art"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .clothing: return "Ropa y Accesorios"
        case .electronics: return "Electrónicos"
        case .furniture: return "Muebles"
        case .books: return "Libros"
        case .sports: return "Deportes"
        case .toys: return "Juguetes"
        case .home: return "Hogar"
        case .beauty: return "Belleza"
        case .automotive: return "Automotriz"
        case .garden: return "Jardín"
        case .food: return "Alimentos"
        case .health: return "Salud"
        case .pets: return "Mascotas"
        case .music: return "Música"
        case .art: return "Arte"
        case .other: return "Otros"
        }
    }
    
    var iconName: String {
        switch self {
        case .clothing: return "tshirt"
        case .electronics: return "desktopcomputer"
        case .furniture: return "bed.double"
        case .books: return "book"
        case .sports: return "sportscourt"
        case .toys: return "gamecontroller"
        case .home: return "house"
        case .beauty: return "sparkles"
        case .automotive: return "car"
        case .garden: return "leaf"
        case .food: return "fork.knife"
        case .health: return "heart"
        case .pets: return "pawprint"
        case .music: return "music.note"
        case .art: return "paintbrush"
        case .other: return "ellipsis.circle"
        }
    }
}

// MARK: - Product Condition
enum ProductCondition: String, CaseIterable, Codable {
    case new = "new"
    case likeNew = "like_new"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    
    var displayName: String {
        switch self {
        case .new: return "Nuevo"
        case .likeNew: return "Como Nuevo"
        case .good: return "Bueno"
        case .fair: return "Aceptable"
        case .poor: return "Necesita Reparación"
        }
    }
    
    var iconName: String {
        switch self {
        case .new: return "sparkles"
        case .likeNew: return "star.fill"
        case .good: return "star"
        case .fair: return "star.leadinghalf.filled"
        case .poor: return "wrench"
        }
    }
    
    var color: String {
        switch self {
        case .new: return "green"
        case .likeNew: return "blue"
        case .good: return "orange"
        case .fair: return "yellow"
        case .poor: return "red"
        }
    }
}

// MARK: - Shipment Status
enum ShipmentStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inTransit = "in_transit"
    case delivered = "delivered"
    case cancelled = "cancelled"
    case returned = "returned"
    
    var displayName: String {
        switch self {
        case .pending: return "Pendiente"
        case .confirmed: return "Confirmado"
        case .inTransit: return "En Tránsito"
        case .delivered: return "Entregado"
        case .cancelled: return "Cancelado"
        case .returned: return "Devuelto"
        }
    }
    
    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .inTransit: return "truck.box"
        case .delivered: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        case .returned: return "arrow.uturn.left"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .inTransit: return "purple"
        case .delivered: return "green"
        case .cancelled: return "red"
        case .returned: return "yellow"
        }
    }
}

// MARK: - Authentication State
enum AuthState {
    case loading
    case signedOut
    case signedIn(User)
    case error(Error)
}

// MARK: - Loading State
enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

// MARK: - Filter Options
enum ProductFilter: String, CaseIterable {
    case all = "all"
    case donations = "donations"
    case forSale = "for_sale"
    case available = "available"
    case recent = "recent"
    
    var displayName: String {
        switch self {
        case .all: return "Todos"
        case .donations: return "Donaciones"
        case .forSale: return "En Venta"
        case .available: return "Disponibles"
        case .recent: return "Recientes"
        }
    }
}

// MARK: - Sort Options
enum ProductSort: String, CaseIterable {
    case newest = "newest"
    case oldest = "oldest"
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case rating = "rating"
    case distance = "distance"
    
    var displayName: String {
        switch self {
        case .newest: return "Más Recientes"
        case .oldest: return "Más Antiguos"
        case .priceAsc: return "Precio: Menor a Mayor"
        case .priceDesc: return "Precio: Mayor a Menor"
        case .rating: return "Mejor Calificados"
        case .distance: return "Distancia"
        }
    }
}

// MARK: - Error Types
enum AppError: Error, LocalizedError {
    case authentication(String)
    case network(String)
    case validation(String)
    case database(String)
    case storage(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .authentication(let message):
            return "Error de autenticación: \(message)"
        case .network(let message):
            return "Error de red: \(message)"
        case .validation(let message):
            return "Error de validación: \(message)"
        case .database(let message):
            return "Error de base de datos: \(message)"
        case .storage(let message):
            return "Error de almacenamiento: \(message)"
        case .unknown(let message):
            return "Error desconocido: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .authentication:
            return "Intenta iniciar sesión nuevamente"
        case .network:
            return "Verifica tu conexión a internet"
        case .validation:
            return "Verifica que los datos sean correctos"
        case .database:
            return "Intenta nuevamente en unos momentos"
        case .storage:
            return "Verifica el espacio disponible"
        case .unknown:
            return "Contacta al soporte técnico"
        }
    }
}

// MARK: - Tab Selection
enum TabSelection: String, CaseIterable {
    case home
    case search
    case add
    case favorites
    case profile
    
    var displayName: String {
        switch self {
        case .home: return "Inicio"
        case .search: return "Buscar"
        case .add: return "Publicar"
        case .favorites: return "Favoritos"
        case .profile: return "Perfil"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .add: return "plus.circle"
        case .favorites: return "heart"
        case .profile: return "person"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .add: return "plus.circle.fill"
        case .favorites: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - Notification Type
enum NotificationType: String, Codable {
    case newMessage = "new_message"
    case newReview = "new_review"
    case productSold = "product_sold"
    case shipmentUpdate = "shipment_update"
    case systemUpdate = "system_update"
    
    var displayName: String {
        switch self {
        case .newMessage: return "Nuevo Mensaje"
        case .newReview: return "Nueva Reseña"
        case .productSold: return "Producto Vendido"
        case .shipmentUpdate: return "Actualización de Envío"
        case .systemUpdate: return "Actualización del Sistema"
        }
    }
    
    var iconName: String {
        switch self {
        case .newMessage: return "message"
        case .newReview: return "star"
        case .productSold: return "cart"
        case .shipmentUpdate: return "truck.box"
        case .systemUpdate: return "gear"
        }
    }
}