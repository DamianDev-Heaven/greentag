//
//  Shipment.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

struct Shipment: Identifiable, Codable, Hashable {
    let id: String
    let productId: String
    let sellerId: String
    let buyerId: String
    let status: ShipmentStatus
    let trackingNumber: String?
    let fromAddress: String
    let toAddress: String
    let estimatedDelivery: Date?
    let actualDelivery: Date?
    let shippingCost: Double
    let createdAt: Date
    let updatedAt: Date
    let notes: String?
    
    // Relational properties (loaded separately)
    var product: Product?
    var seller: User?
    var buyer: User?
    
    // MARK: - Computed Properties
    var statusColor: String {
        status.color
    }
    
    var statusIcon: String {
        status.iconName
    }
    
    var statusDisplayName: String {
        status.displayName
    }
    
    var formattedShippingCost: String {
        if shippingCost == 0 {
            return "Gratis"
        } else {
            return String(format: "%.2f €", shippingCost)
        }
    }
    
    var estimatedDeliveryString: String? {
        guard let estimatedDelivery = estimatedDelivery else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: estimatedDelivery)
    }
    
    var actualDeliveryString: String? {
        guard let actualDelivery = actualDelivery else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: actualDelivery)
    }
    
    var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    // MARK: - CodingKeys for Supabase snake_case conversion
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case sellerId = "seller_id"
        case buyerId = "buyer_id"
        case status
        case trackingNumber = "tracking_number"
        case fromAddress = "from_address"
        case toAddress = "to_address"
        case estimatedDelivery = "estimated_delivery"
        case actualDelivery = "actual_delivery"
        case shippingCost = "shipping_cost"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case notes
    }
    
    // MARK: - Initializers
    init(
        id: String = UUID().uuidString,
        productId: String,
        sellerId: String,
        buyerId: String,
        status: ShipmentStatus = .pending,
        trackingNumber: String? = nil,
        fromAddress: String,
        toAddress: String,
        estimatedDelivery: Date? = nil,
        actualDelivery: Date? = nil,
        shippingCost: Double = 0.0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        notes: String? = nil,
        product: Product? = nil,
        seller: User? = nil,
        buyer: User? = nil
    ) {
        self.id = id
        self.productId = productId
        self.sellerId = sellerId
        self.buyerId = buyerId
        self.status = status
        self.trackingNumber = trackingNumber
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.estimatedDelivery = estimatedDelivery
        self.actualDelivery = actualDelivery
        self.shippingCost = shippingCost
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.product = product
        self.seller = seller
        self.buyer = buyer
    }
}

enum ShipmentStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case shipped = "shipped"
    case inTransit = "in_transit"
    case delivered = "delivered"
    case cancelled = "cancelled"
    case returned = "returned"
    
    var displayName: String {
        switch self {
        case .pending: return "Pendiente"
        case .confirmed: return "Confirmado"
        case .shipped: return "Enviado"
        case .inTransit: return "En tránsito"
        case .delivered: return "Entregado"
        case .cancelled: return "Cancelado"
        case .returned: return "Devuelto"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .shipped: return "purple"
        case .inTransit: return "indigo"
        case .delivered: return "green"
        case .cancelled: return "red"
        case .returned: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .shipped: return "shippingbox"
        case .inTransit: return "truck.box"
        case .delivered: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        case .returned: return "arrow.uturn.left"
        }
    }
}

enum ShippingMethod: String, CaseIterable, Codable {
    case standard = "standard"
    case express = "express"
    case overnight = "overnight"
    case pickup = "pickup"
    case meetup = "meetup"
    
    var displayName: String {
        switch self {
        case .standard: return "Envío estándar"
        case .express: return "Envío express"
        case .overnight: return "Entrega 24h"
        case .pickup: return "Recogida en punto"
        case .meetup: return "Encuentro personal"
        }
    }
    
    var estimatedDays: Int {
        switch self {
        case .standard: return 5
        case .express: return 2
        case .overnight: return 1
        case .pickup: return 3
        case .meetup: return 1
        }
    }
}

struct Address: Codable, Hashable {
    let street: String
    let city: String
    let postalCode: String
    let country: String
    let recipientName: String
    let phoneNumber: String?
    
    var fullAddress: String {
        "\(street), \(postalCode) \(city), \(country)"
    }
}

// MARK: - Sample Data
extension Shipment {
    static let sampleShipments: [Shipment] = [
        Shipment(
            productId: "product1",
            productTitle: "iPhone 12 Pro",
            productImageURL: "https://example.com/iphone1.jpg",
            sellerId: "user1",
            sellerName: "Ana García",
            buyerId: "user3",
            buyerName: "Pedro Morales",
            status: .inTransit,
            trackingNumber: "GT123456789",
            shippingMethod: .express,
            fromAddress: Address(
                street: "Calle Mayor 123",
                city: "Madrid",
                postalCode: "28001",
                country: "España",
                recipientName: "Ana García",
                phoneNumber: "+34 123 456 789"
            ),
            toAddress: Address(
                street: "Avenida Libertad 456",
                city: "Valencia",
                postalCode: "46001",
                country: "España",
                recipientName: "Pedro Morales",
                phoneNumber: "+34 987 654 321"
            ),
            estimatedDelivery: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            shippingCost: 8.99,
            notes: "Entregar en conserjería si no hay nadie en casa"
        )
    ]
}