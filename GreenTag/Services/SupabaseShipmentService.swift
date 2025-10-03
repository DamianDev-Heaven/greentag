//
//  ShipmentService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Supabase

class ShipmentService {
    static let shared = ShipmentService()
    
    private let supabaseManager = SupabaseManager.shared
    
    private init() {}
    
    // MARK: - Shipment CRUD Operations
    
    func createShipment(_ shipment: Shipment) async throws -> Shipment {
        do {
            let response: Shipment = try await supabaseManager.client
                .from("shipments")
                .insert(shipment)
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al crear envío: \(error.localizedDescription)")
        }
    }
    
    func getShipment(id: String) async throws -> Shipment {
        do {
            let response: Shipment = try await supabaseManager.client
                .from("shipments")
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener envío: \(error.localizedDescription)")
        }
    }
    
    func updateShipment(_ shipment: Shipment) async throws -> Shipment {
        do {
            let updatedShipment = Shipment(
                id: shipment.id,
                productId: shipment.productId,
                sellerId: shipment.sellerId,
                buyerId: shipment.buyerId,
                status: shipment.status,
                trackingNumber: shipment.trackingNumber,
                fromAddress: shipment.fromAddress,
                toAddress: shipment.toAddress,
                estimatedDelivery: shipment.estimatedDelivery,
                actualDelivery: shipment.actualDelivery,
                shippingCost: shipment.shippingCost,
                createdAt: shipment.createdAt,
                updatedAt: Date(),
                notes: shipment.notes
            )
            
            let response: Shipment = try await supabaseManager.client
                .from("shipments")
                .update(updatedShipment)
                .eq("id", value: shipment.id)
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al actualizar envío: \(error.localizedDescription)")
        }
    }
    
    func updateShipmentStatus(id: String, status: ShipmentStatus, trackingNumber: String? = nil) async throws -> Shipment {
        do {
            var updateData: [String: Any] = [
                "status": status.rawValue,
                "updated_at": Date()
            ]
            
            if let trackingNumber = trackingNumber {
                updateData["tracking_number"] = trackingNumber
            }
            
            if status == .delivered {
                updateData["actual_delivery"] = Date()
            }
            
            let response: Shipment = try await supabaseManager.client
                .from("shipments")
                .update(updateData)
                .eq("id", value: id)
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al actualizar estado del envío: \(error.localizedDescription)")
        }
    }
    
    func deleteShipment(id: String) async throws {
        do {
            try await supabaseManager.client
                .from("shipments")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            throw AppError.database("Error al eliminar envío: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Shipment Queries
    
    func getUserShipments(
        userId: String,
        limit: Int = 20,
        offset: Int = 0,
        isSeller: Bool = true
    ) async throws -> [Shipment] {
        do {
            let column = isSeller ? "seller_id" : "buyer_id"
            
            let response: [Shipment] = try await supabaseManager.client
                .from("shipments")
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .eq(column, value: userId)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener envíos del usuario: \(error.localizedDescription)")
        }
    }
    
    func getProductShipments(productId: String) async throws -> [Shipment] {
        do {
            let response: [Shipment] = try await supabaseManager.client
                .from("shipments")
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .eq("product_id", value: productId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener envíos del producto: \(error.localizedDescription)")
        }
    }
    
    func getShipmentsByStatus(
        status: ShipmentStatus,
        userId: String? = nil,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [Shipment] {
        do {
            var query = supabaseManager.client
                .from("shipments")
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .eq("status", value: status.rawValue)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
            
            if let userId = userId {
                query = query.or("seller_id.eq.\(userId),buyer_id.eq.\(userId)")
            }
            
            let response: [Shipment] = try await query.execute().value
            return response
        } catch {
            throw AppError.database("Error al obtener envíos por estado: \(error.localizedDescription)")
        }
    }
    
    func getActiveShipments(userId: String) async throws -> [Shipment] {
        do {
            let activeStatuses = [
                ShipmentStatus.pending.rawValue,
                ShipmentStatus.confirmed.rawValue,
                ShipmentStatus.inTransit.rawValue
            ]
            
            let response: [Shipment] = try await supabaseManager.client
                .from("shipments")
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .in("status", values: activeStatuses)
                .or("seller_id.eq.\(userId),buyer_id.eq.\(userId)")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener envíos activos: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Shipment Statistics
    
    func getUserShipmentStats(userId: String) async throws -> UserShipmentStats {
        do {
            let response: UserShipmentStats = try await supabaseManager.client
                .rpc("get_user_shipment_stats", params: ["user_id": userId])
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener estadísticas de envío: \(error.localizedDescription)")
        }
    }
    
    func getShipmentHistory(userId: String, limit: Int = 50, offset: Int = 0) async throws -> [Shipment] {
        do {
            let response: [Shipment] = try await supabaseManager.client
                .from("shipments")
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .or("seller_id.eq.\(userId),buyer_id.eq.\(userId)")
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener historial de envíos: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Shipment Tracking
    
    func trackShipment(trackingNumber: String) async throws -> ShipmentTrackingInfo? {
        // This would integrate with external tracking APIs (DHL, UPS, etc.)
        // For now, return basic info from our database
        do {
            let response: Shipment = try await supabaseManager.client
                .from("shipments")
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .eq("tracking_number", value: trackingNumber)
                .single()
                .execute()
                .value
            
            return ShipmentTrackingInfo(
                trackingNumber: trackingNumber,
                status: response.status,
                estimatedDelivery: response.estimatedDelivery,
                actualDelivery: response.actualDelivery,
                lastUpdate: response.updatedAt
            )
        } catch {
            return nil
        }
    }
    
    // MARK: - Shipment Actions
    
    func confirmShipment(id: String, trackingNumber: String? = nil, estimatedDelivery: Date? = nil) async throws -> Shipment {
        do {
            var updateData: [String: Any] = [
                "status": ShipmentStatus.confirmed.rawValue,
                "updated_at": Date()
            ]
            
            if let trackingNumber = trackingNumber {
                updateData["tracking_number"] = trackingNumber
            }
            
            if let estimatedDelivery = estimatedDelivery {
                updateData["estimated_delivery"] = estimatedDelivery
            }
            
            let response: Shipment = try await supabaseManager.client
                .from("shipments")
                .update(updateData)
                .eq("id", value: id)
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al confirmar envío: \(error.localizedDescription)")
        }
    }
    
    func cancelShipment(id: String, reason: String? = nil) async throws -> Shipment {
        do {
            var updateData: [String: Any] = [
                "status": ShipmentStatus.cancelled.rawValue,
                "updated_at": Date()
            ]
            
            if let reason = reason {
                updateData["notes"] = reason
            }
            
            let response: Shipment = try await supabaseManager.client
                .from("shipments")
                .update(updateData)
                .eq("id", value: id)
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al cancelar envío: \(error.localizedDescription)")
        }
    }
    
    func markAsDelivered(id: String) async throws -> Shipment {
        do {
            let updateData: [String: Any] = [
                "status": ShipmentStatus.delivered.rawValue,
                "actual_delivery": Date(),
                "updated_at": Date()
            ]
            
            let response: Shipment = try await supabaseManager.client
                .from("shipments")
                .update(updateData)
                .eq("id", value: id)
                .select("""
                    *,
                    product:products(*),
                    seller:profiles!seller_id(*),
                    buyer:profiles!buyer_id(*)
                """)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al marcar como entregado: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Real-time Subscriptions
    
    func subscribeToUserShipments(userId: String) -> AsyncStream<Shipment> {
        return AsyncStream { continuation in
            let channel = supabaseManager.client.realtime.channel("user-shipments-\(userId)")
            
            Task {
                await channel
                    .on("postgres_changes", filter: ChannelFilter(
                        event: "UPDATE",
                        schema: "public",
                        table: "shipments",
                        filter: "or(seller_id.eq.\(userId),buyer_id.eq.\(userId))"
                    )) { payload in
                        if let shipment = try? JSONDecoder().decode(Shipment.self, from: JSONSerialization.data(withJSONObject: payload.new)) {
                            continuation.yield(shipment)
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
    
    func subscribeToShipmentUpdates(shipmentId: String) -> AsyncStream<Shipment> {
        return AsyncStream { continuation in
            let channel = supabaseManager.client.realtime.channel("shipment-\(shipmentId)")
            
            Task {
                await channel
                    .on("postgres_changes", filter: ChannelFilter(
                        event: "UPDATE",
                        schema: "public",
                        table: "shipments",
                        filter: "id=eq.\(shipmentId)"
                    )) { payload in
                        if let shipment = try? JSONDecoder().decode(Shipment.self, from: JSONSerialization.data(withJSONObject: payload.new)) {
                            continuation.yield(shipment)
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

// MARK: - Supporting Types

struct UserShipmentStats: Codable {
    let totalShipments: Int
    let pendingShipments: Int
    let confirmedShipments: Int
    let inTransitShipments: Int
    let deliveredShipments: Int
    let cancelledShipments: Int
    let averageDeliveryTime: Double? // in days
    
    enum CodingKeys: String, CodingKey {
        case totalShipments = "total_shipments"
        case pendingShipments = "pending_shipments"
        case confirmedShipments = "confirmed_shipments"
        case inTransitShipments = "in_transit_shipments"
        case deliveredShipments = "delivered_shipments"
        case cancelledShipments = "cancelled_shipments"
        case averageDeliveryTime = "average_delivery_time"
    }
}

struct ShipmentTrackingInfo: Codable {
    let trackingNumber: String
    let status: ShipmentStatus
    let estimatedDelivery: Date?
    let actualDelivery: Date?
    let lastUpdate: Date
    
    enum CodingKeys: String, CodingKey {
        case trackingNumber = "tracking_number"
        case status
        case estimatedDelivery = "estimated_delivery"
        case actualDelivery = "actual_delivery"
        case lastUpdate = "last_update"
    }
}