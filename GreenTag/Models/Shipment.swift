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
    let productTitle: String
    let productImageURL: String?
    let sellerId: String
    let sellerName: String
    let buyerId: String
    let buyerName: String
    let status: ShipmentStatus
    let trackingNumber: String?
    let shippingMethod: ShippingMethod
    let fromAddress: Address
    let toAddress: Address
    let estimatedDelivery: Date?
    let actualDelivery: Date?
    let shippingCost: Double
    let createdAt: Date
    let updatedAt: Date
    let notes: String?
    
    var statusColor: String {
        status.color
    }
    
    var statusIcon: String {
        status.icon
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
    
    init(
        id: String = UUID().uuidString,
        productId: String,
        productTitle: String,
        productImageURL: String? = nil,
        sellerId: String,
        sellerName: String,
        buyerId: String,
        buyerName: String,
        status: ShipmentStatus = .pending,
        trackingNumber: String? = nil,
        shippingMethod: ShippingMethod,
        fromAddress: Address,
        toAddress: Address,
        estimatedDelivery: Date? = nil,
        actualDelivery: Date? = nil,
        shippingCost: Double = 0.0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.productId = productId
        self.productTitle = productTitle
        self.productImageURL = productImageURL
        self.sellerId = sellerId
        self.sellerName = sellerName
        self.buyerId = buyerId
        self.buyerName = buyerName
        self.status = status
        self.trackingNumber = trackingNumber
        self.shippingMethod = shippingMethod
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.estimatedDelivery = estimatedDelivery
        self.actualDelivery = actualDelivery
        self.shippingCost = shippingCost
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
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