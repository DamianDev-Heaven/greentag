//
//  Review.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

struct Review: Identifiable, Codable, Hashable {
    let id: String
    let reviewerId: String
    let reviewedUserId: String
    let productId: String?
    let rating: Int
    let comment: String
    let createdAt: Date
    let updatedAt: Date
    let isVerified: Bool
    
    // Relational properties (loaded separately)
    var reviewer: User?
    var reviewedUser: User?
    var product: Product?
    
    // MARK: - Computed Properties
    var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var ratingStars: String {
        String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    // MARK: - CodingKeys for Supabase snake_case conversion
    enum CodingKeys: String, CodingKey {
        case id
        case reviewerId = "reviewer_id"
        case reviewedUserId = "reviewed_user_id"
        case productId = "product_id"
        case rating
        case comment
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isVerified = "is_verified"
    }
    
    // MARK: - Initializers
    init(
        id: String = UUID().uuidString,
        reviewerId: String,
        reviewedUserId: String,
        productId: String? = nil,
        rating: Int,
        comment: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isVerified: Bool = false,
        reviewer: User? = nil,
        reviewedUser: User? = nil,
        product: Product? = nil
    ) {
        self.id = id
        self.reviewerId = reviewerId
        self.reviewedUserId = reviewedUserId
        self.productId = productId
        self.rating = max(1, min(5, rating)) // Ensure rating is between 1-5
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isVerified = isVerified
        self.reviewer = reviewer
        self.reviewedUser = reviewedUser
        self.product = product
    }
}

// MARK: - Sample Data
extension Review {
    static let sampleReviews: [Review] = [
        Review(
            reviewerId: "reviewer1",
            reviewerName: "María López",
            reviewedUserId: "user1",
            productId: "product1",
            rating: 5,
            comment: "Excelente vendedora, el producto llegó en perfectas condiciones y muy rápido. ¡Totalmente recomendable!",
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            isVerified: true
        ),
        Review(
            reviewerId: "reviewer2",
            reviewerName: "Juan Martínez",
            reviewedUserId: "user1",
            rating: 4,
            comment: "Muy buena comunicación y el producto tal como se describía. Envío un poco lento pero todo perfecto.",
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            isVerified: true
        ),
        Review(
            reviewerId: "reviewer3",
            reviewerName: "Laura Sánchez",
            reviewedUserId: "user2",
            productId: "product2",
            rating: 5,
            comment: "Los libros llegaron en perfecto estado. Ana es muy amable y responsable. ¡Gracias por la donación!",
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            isVerified: false
        )
    ]
}