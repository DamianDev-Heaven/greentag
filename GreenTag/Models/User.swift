//
//  User.swift  
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let country: String?
    let city: String?
    let profileImageURL: String?
    let averageRating: Double
    let totalReviews: Int
    let ecoPoints: Int
    let createdAt: Date
    let updatedAt: Date
    let isVerified: Bool
    
    // MARK: - Computed Properties
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var displayRating: String {
        String(format: "%.1f", averageRating)
    }
    
    var memberSinceFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
    
    // MARK: - CodingKeys for Supabase snake_case conversion
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case country
        case city
        case profileImageURL = "profile_image_url"
        case averageRating = "average_rating"
        case totalReviews = "total_reviews"
        case ecoPoints = "eco_points"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isVerified = "is_verified"
    }
    
    // MARK: - Initializers
    init(
        id: String = UUID().uuidString,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String? = nil,
        country: String? = nil,
        city: String? = nil,
        profileImageURL: String? = nil,
        averageRating: Double = 0.0,
        totalReviews: Int = 0,
        ecoPoints: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isVerified: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.country = country
        self.city = city
        self.profileImageURL = profileImageURL
        self.averageRating = averageRating
        self.totalReviews = totalReviews
        self.ecoPoints = ecoPoints
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isVerified = isVerified
    }
}

// MARK: - Sample Data
extension User {
    static let sampleUsers: [User] = [
        User(
            firstName: "Ana",
            lastName: "García",
            email: "ana.garcia@email.com",
            phoneNumber: "+34 123 456 789",
            country: "España",
            city: "Madrid",
            averageRating: 4.8,
            totalReviews: 25,
            ecoPoints: 1250,
            isVerified: true
        ),
        User(
            firstName: "Carlos",
            lastName: "Rodríguez",
            email: "carlos.rodriguez@email.com",
            phoneNumber: "+34 987 654 321",
            country: "España",
            city: "Barcelona",
            averageRating: 4.6,
            totalReviews: 18,
            ecoPoints: 980,
            isVerified: false
        )
    ]
}