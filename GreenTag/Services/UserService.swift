//
//  UserService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

class UserService {
    private let networkManager = NetworkManager.shared
    
    // MARK: - User Operations
    
    func fetchUser(by id: String) async throws -> User {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Mock implementation
        if let user = User.sampleUsers.first(where: { $0.id == id }) {
            return user
        }
        
        throw UserError.userNotFound
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/users/\(id)",
        //     method: .GET
        // )
        // return try JSONDecoder().decode(User.self, from: response)
    }
    
    func updateUser(_ user: User) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock implementation
        return user
        
        // Actual API call:
        // let encoder = JSONEncoder()
        // let userData = try encoder.encode(user)
        // 
        // let response = try await networkManager.request(
        //     endpoint: "/users/\(user.id)",
        //     method: .PUT,
        //     body: userData
        // )
        // return try JSONDecoder().decode(User.self, from: response)
    }
    
    func uploadProfileImage(_ imageData: Data, userId: String) async throws -> String {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Mock implementation - return a fake URL
        return "https://example.com/profile-images/\(userId)-\(UUID().uuidString).jpg"
        
        // Actual API call:
        // let response = try await networkManager.uploadImage(
        //     imageData: imageData,
        //     endpoint: "/users/\(userId)/profile-image"
        // )
        // let uploadResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: response)
        // return uploadResponse.imageURL
    }
    
    // MARK: - Reviews Operations
    
    func fetchUserReviews(userId: String) async throws -> [Review] {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Mock implementation
        return Review.sampleReviews.filter { $0.reviewedUserId == userId }
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/users/\(userId)/reviews",
        //     method: .GET
        // )
        // return try JSONDecoder().decode([Review].self, from: response)
    }
    
    func createReview(_ review: Review) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock implementation
        print("Review created for user: \(review.reviewedUserId)")
        
        // Actual API call:
        // let encoder = JSONEncoder()
        // let reviewData = try encoder.encode(review)
        // 
        // let _ = try await networkManager.request(
        //     endpoint: "/reviews",
        //     method: .POST,
        //     body: reviewData
        // )
    }
    
    // MARK: - Shipments Operations
    
    func fetchUserShipments(userId: String) async throws -> [Shipment] {
        try await Task.sleep(nanoseconds: 700_000_000)
        
        // Mock implementation
        return Shipment.sampleShipments.filter { 
            $0.sellerId == userId || $0.buyerId == userId 
        }
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/users/\(userId)/shipments",
        //     method: .GET
        // )
        // return try JSONDecoder().decode([Shipment].self, from: response)
    }
    
    func updateShipmentStatus(shipmentId: String, status: ShipmentStatus) async throws {
        let parameters = ["status": status.rawValue]
        
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Mock implementation
        print("Shipment \(shipmentId) status updated to: \(status.displayName)")
        
        // Actual API call:
        // let _ = try await networkManager.request(
        //     endpoint: "/shipments/\(shipmentId)/status",
        //     method: .PUT,
        //     parameters: parameters
        // )
    }
    
    // MARK: - Rankings Operations
    
    func fetchRankings(period: RankingPeriod, leaderboard: LeaderboardType) async throws -> [Ranking] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock implementation
        return Ranking.sampleRankings
        
        // Actual API call:
        // let parameters = [
        //     "period": period.rawValue,
        //     "leaderboard": leaderboard.rawValue
        // ]
        // 
        // let response = try await networkManager.request(
        //     endpoint: "/rankings",
        //     method: .GET,
        //     parameters: parameters
        // )
        // return try JSONDecoder().decode([Ranking].self, from: response)
    }
    
    func fetchUserRanking(userId: String, period: RankingPeriod, leaderboard: LeaderboardType) async throws -> Ranking {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Mock implementation
        if let ranking = Ranking.sampleRankings.first(where: { $0.userId == userId }) {
            return ranking
        }
        
        throw UserError.rankingNotFound
        
        // Actual API call:
        // let parameters = [
        //     "period": period.rawValue,
        //     "leaderboard": leaderboard.rawValue
        // ]
        // 
        // let response = try await networkManager.request(
        //     endpoint: "/users/\(userId)/ranking",
        //     method: .GET,
        //     parameters: parameters
        // )
        // return try JSONDecoder().decode(Ranking.self, from: response)
    }
    
    // MARK: - Eco Points Operations
    
    func addEcoPoints(userId: String, points: Int, reason: String) async throws {
        let parameters = [
            "points": points,
            "reason": reason
        ] as [String : Any]
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock implementation
        print("Added \(points) eco points to user \(userId) for: \(reason)")
        
        // Actual API call:
        // let _ = try await networkManager.request(
        //     endpoint: "/users/\(userId)/eco-points",
        //     method: .POST,
        //     parameters: parameters
        // )
    }
    
    func fetchEcoPointsHistory(userId: String) async throws -> [EcoPointsTransaction] {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Mock implementation
        return []
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/users/\(userId)/eco-points/history",
        //     method: .GET
        // )
        // return try JSONDecoder().decode([EcoPointsTransaction].self, from: response)
    }
    
    // MARK: - Badge Operations
    
    func fetchUserBadges(userId: String) async throws -> [EcoBadge] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock implementation
        if let ranking = Ranking.sampleRankings.first(where: { $0.userId == userId }) {
            return ranking.badgesEarned
        }
        
        return []
        
        // Actual API call:
        // let response = try await networkManager.request(
        //     endpoint: "/users/\(userId)/badges",
        //     method: .GET
        // )
        // return try JSONDecoder().decode([EcoBadge].self, from: response)
    }
}

// MARK: - Supporting Models

struct EcoPointsTransaction: Identifiable, Codable {
    let id: String
    let userId: String
    let points: Int
    let reason: String
    let createdAt: Date
    let type: TransactionType
    
    enum TransactionType: String, Codable {
        case earned = "earned"
        case spent = "spent"
        case bonus = "bonus"
    }
}

struct ImageUploadResponse: Codable {
    let imageURL: String
    let thumbnailURL: String?
}

// MARK: - User Errors

enum UserError: LocalizedError {
    case userNotFound
    case invalidUserData
    case rankingNotFound
    case insufficientPoints
    case networkError
    case unauthorizedAccess
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Usuario no encontrado"
        case .invalidUserData:
            return "Datos de usuario inválidos"
        case .rankingNotFound:
            return "Ranking no encontrado para este usuario"
        case .insufficientPoints:
            return "Puntos eco insuficientes"
        case .networkError:
            return "Error de conexión"
        case .unauthorizedAccess:
            return "No tienes permisos para esta acción"
        case .unknownError:
            return "Ha ocurrido un error inesperado"
        }
    }
}