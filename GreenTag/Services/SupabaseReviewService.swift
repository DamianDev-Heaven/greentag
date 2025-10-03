//
//  ReviewService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Supabase

class ReviewService {
    static let shared = ReviewService()
    
    private let supabaseManager = SupabaseManager.shared
    
    private init() {}
    
    // MARK: - Review CRUD Operations
    
    func createReview(_ review: Review) async throws -> Review {
        do {
            let response: Review = try await supabaseManager.client
                .from("reviews")
                .insert(review)
                .select("""
                    *,
                    reviewer:profiles!reviewer_id(*),
                    reviewed_user:profiles!reviewed_user_id(*),
                    product:products(*)
                """)
                .single()
                .execute()
                .value
            
            // Update user's average rating
            try await updateUserAverageRating(userId: review.reviewedUserId)
            
            return response
        } catch {
            throw AppError.database("Error al crear reseña: \(error.localizedDescription)")
        }
    }
    
    func getReview(id: String) async throws -> Review {
        do {
            let response: Review = try await supabaseManager.client
                .from("reviews")
                .select("""
                    *,
                    reviewer:profiles!reviewer_id(*),
                    reviewed_user:profiles!reviewed_user_id(*),
                    product:products(*)
                """)
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener reseña: \(error.localizedDescription)")
        }
    }
    
    func updateReview(_ review: Review) async throws -> Review {
        do {
            let updatedReview = Review(
                id: review.id,
                reviewerId: review.reviewerId,
                reviewedUserId: review.reviewedUserId,
                productId: review.productId,
                rating: review.rating,
                comment: review.comment,
                createdAt: review.createdAt,
                updatedAt: Date(),
                isVerified: review.isVerified
            )
            
            let response: Review = try await supabaseManager.client
                .from("reviews")
                .update(updatedReview)
                .eq("id", value: review.id)
                .select("""
                    *,
                    reviewer:profiles!reviewer_id(*),
                    reviewed_user:profiles!reviewed_user_id(*),
                    product:products(*)
                """)
                .single()
                .execute()
                .value
            
            // Update user's average rating
            try await updateUserAverageRating(userId: review.reviewedUserId)
            
            return response
        } catch {
            throw AppError.database("Error al actualizar reseña: \(error.localizedDescription)")
        }
    }
    
    func deleteReview(id: String, reviewedUserId: String) async throws {
        do {
            try await supabaseManager.client
                .from("reviews")
                .delete()
                .eq("id", value: id)
                .execute()
            
            // Update user's average rating
            try await updateUserAverageRating(userId: reviewedUserId)
        } catch {
            throw AppError.database("Error al eliminar reseña: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Review Queries
    
    func getUserReviews(
        userId: String,
        limit: Int = 20,
        offset: Int = 0,
        isReviewer: Bool = false
    ) async throws -> [Review] {
        do {
            let column = isReviewer ? "reviewer_id" : "reviewed_user_id"
            
            let response: [Review] = try await supabaseManager.client
                .from("reviews")
                .select("""
                    *,
                    reviewer:profiles!reviewer_id(*),
                    reviewed_user:profiles!reviewed_user_id(*),
                    product:products(*)
                """)
                .eq(column, value: userId)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener reseñas del usuario: \(error.localizedDescription)")
        }
    }
    
    func getProductReviews(
        productId: String,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [Review] {
        do {
            let response: [Review] = try await supabaseManager.client
                .from("reviews")
                .select("""
                    *,
                    reviewer:profiles!reviewer_id(*),
                    reviewed_user:profiles!reviewed_user_id(*),
                    product:products(*)
                """)
                .eq("product_id", value: productId)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener reseñas del producto: \(error.localizedDescription)")
        }
    }
    
    func getRecentReviews(limit: Int = 10) async throws -> [Review] {
        do {
            let response: [Review] = try await supabaseManager.client
                .from("reviews")
                .select("""
                    *,
                    reviewer:profiles!reviewer_id(*),
                    reviewed_user:profiles!reviewed_user_id(*),
                    product:products(*)
                """)
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener reseñas recientes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Review Statistics
    
    func getUserRatingStats(userId: String) async throws -> UserRatingStats {
        do {
            let response: UserRatingStats = try await supabaseManager.client
                .rpc("get_user_rating_stats", params: ["user_id": userId])
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener estadísticas de calificación: \(error.localizedDescription)")
        }
    }
    
    func getProductRatingStats(productId: String) async throws -> ProductRatingStats {
        do {
            let response: ProductRatingStats = try await supabaseManager.client
                .rpc("get_product_rating_stats", params: ["product_id": productId])
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener estadísticas del producto: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Review Validation
    
    func canUserReviewUser(reviewerId: String, reviewedUserId: String) async throws -> Bool {
        // User cannot review themselves
        if reviewerId == reviewedUserId {
            return false
        }
        
        do {
            // Check if user has already reviewed this user
            let existingReviews: [Review] = try await supabaseManager.client
                .from("reviews")
                .select("id")
                .eq("reviewer_id", value: reviewerId)
                .eq("reviewed_user_id", value: reviewedUserId)
                .execute()
                .value
            
            return existingReviews.isEmpty
        } catch {
            return false
        }
    }
    
    func canUserReviewProduct(reviewerId: String, productId: String) async throws -> Bool {
        do {
            // Get product to check if user is the seller
            let product: Product = try await supabaseManager.client
                .from("products")
                .select("seller_id")
                .eq("id", value: productId)
                .single()
                .execute()
                .value
            
            // User cannot review their own product
            if product.sellerId == reviewerId {
                return false
            }
            
            // Check if user has already reviewed this product
            let existingReviews: [Review] = try await supabaseManager.client
                .from("reviews")
                .select("id")
                .eq("reviewer_id", value: reviewerId)
                .eq("product_id", value: productId)
                .execute()
                .value
            
            return existingReviews.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateUserAverageRating(userId: String) async throws {
        do {
            try await supabaseManager.client
                .rpc("update_user_average_rating", params: ["user_id": userId])
                .execute()
        } catch {
            // Log error but don't throw - this is a secondary operation
            print("Error updating user average rating: \(error)")
        }
    }
    
    // MARK: - Real-time Subscriptions
    
    func subscribeToUserReviews(userId: String) -> AsyncStream<Review> {
        return AsyncStream { continuation in
            let channel = supabaseManager.client.realtime.channel("user-reviews-\(userId)")
            
            Task {
                await channel
                    .on("postgres_changes", filter: ChannelFilter(
                        event: "INSERT",
                        schema: "public",
                        table: "reviews",
                        filter: "reviewed_user_id=eq.\(userId)"
                    )) { payload in
                        if let review = try? JSONDecoder().decode(Review.self, from: JSONSerialization.data(withJSONObject: payload.new)) {
                            continuation.yield(review)
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
    
    func subscribeToProductReviews(productId: String) -> AsyncStream<Review> {
        return AsyncStream { continuation in
            let channel = supabaseManager.client.realtime.channel("product-reviews-\(productId)")
            
            Task {
                await channel
                    .on("postgres_changes", filter: ChannelFilter(
                        event: "INSERT",
                        schema: "public",
                        table: "reviews",
                        filter: "product_id=eq.\(productId)"
                    )) { payload in
                        if let review = try? JSONDecoder().decode(Review.self, from: JSONSerialization.data(withJSONObject: payload.new)) {
                            continuation.yield(review)
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

struct UserRatingStats: Codable {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [Int: Int] // Rating (1-5) to count
    
    enum CodingKeys: String, CodingKey {
        case averageRating = "average_rating"
        case totalReviews = "total_reviews"
        case ratingDistribution = "rating_distribution"
    }
}

struct ProductRatingStats: Codable {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [Int: Int]
    
    enum CodingKeys: String, CodingKey {
        case averageRating = "average_rating"
        case totalReviews = "total_reviews"
        case ratingDistribution = "rating_distribution"
    }
}