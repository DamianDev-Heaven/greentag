//
//  FirebaseConfig.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseConfig {
    static let shared = FirebaseConfig()
    
    private init() {}
    
    func configure() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Firestore
        configureFirestore()
        
        // Configure Auth
        configureAuth()
        
        // Configure Storage
        configureStorage()
        
        print("✅ Firebase configured successfully")
    }
    
    private func configureFirestore() {
        let db = Firestore.firestore()
        
        // Enable offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        
        db.settings = settings
        
        print("✅ Firestore configured with offline persistence")
    }
    
    private func configureAuth() {
        // Auth configuration is automatically handled by Firebase
        print("✅ Firebase Auth configured")
    }
    
    private func configureStorage() {
        let storage = Storage.storage()
        
        // Set maximum upload/download timeout
        storage.maxUploadRetryTime = 120
        storage.maxDownloadRetryTime = 120
        
        print("✅ Firebase Storage configured")
    }
    
    // MARK: - Security Rules Templates
    
    static let firestoreRulesTemplate = """
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Users collection
        match /users/{userId} {
          allow read: if request.auth != null;
          allow write: if request.auth != null && request.auth.uid == userId;
        }
        
        // Products collection
        match /products/{productId} {
          allow read: if request.auth != null;
          allow create: if request.auth != null && request.auth.uid == resource.data.sellerId;
          allow update, delete: if request.auth != null && request.auth.uid == resource.data.sellerId;
        }
        
        // Reviews collection
        match /reviews/{reviewId} {
          allow read: if request.auth != null;
          allow create: if request.auth != null && request.auth.uid == resource.data.reviewerId;
          allow update, delete: if request.auth != null && request.auth.uid == resource.data.reviewerId;
        }
        
        // Shipments collection
        match /shipments/{shipmentId} {
          allow read, write: if request.auth != null && 
            (request.auth.uid == resource.data.buyerId || request.auth.uid == resource.data.sellerId);
        }
        
        // Rankings collection
        match /rankings/{rankingId} {
          allow read: if request.auth != null;
          allow write: if false; // Only server can write rankings
        }
        
        // Conversations collection
        match /conversations/{conversationId} {
          allow read, write: if request.auth != null && 
            request.auth.uid in resource.data.participantIds;
        }
        
        // Messages subcollection
        match /conversations/{conversationId}/messages/{messageId} {
          allow read, write: if request.auth != null && 
            request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participantIds;
        }
      }
    }
    """
    
    static let storageRulesTemplate = """
    rules_version = '2';
    service firebase.storage {
      match /b/{bucket}/o {
        // User profile images
        match /user_profiles/{userId}/{allPaths=**} {
          allow read: if request.auth != null;
          allow write: if request.auth != null && request.auth.uid == userId;
        }
        
        // Product images
        match /product_images/{productId}/{allPaths=**} {
          allow read: if request.auth != null;
          allow write: if request.auth != null;
        }
        
        // Review images
        match /review_images/{reviewId}/{allPaths=**} {
          allow read: if request.auth != null;
          allow write: if request.auth != null;
        }
      }
    }
    """
}

// MARK: - Firebase Collections Helper

extension FirebaseCollections {
    static func validateCollectionName(_ name: String) -> Bool {
        let validPattern = "^[a-zA-Z][a-zA-Z0-9_]*$"
        let regex = try? NSRegularExpression(pattern: validPattern)
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex?.firstMatch(in: name, range: range) != nil
    }
}

// MARK: - Firebase Environment Configuration

enum FirebaseEnvironment {
    case development
    case staging
    case production
    
    var databaseURL: String {
        switch self {
        case .development:
            return "https://greentag-dev-default-rtdb.firebaseio.com/"
        case .staging:
            return "https://greentag-staging-default-rtdb.firebaseio.com/"
        case .production:
            return "https://greentag-prod-default-rtdb.firebaseio.com/"
        }
    }
    
    var storageBucket: String {
        switch self {
        case .development:
            return "greentag-dev.appspot.com"
        case .staging:
            return "greentag-staging.appspot.com"
        case .production:
            return "greentag-prod.appspot.com"
        }
    }
}

// MARK: - Firebase Analytics Events

struct FirebaseAnalyticsEvents {
    static let userSignUp = "user_sign_up"
    static let userSignIn = "user_sign_in"
    static let productCreated = "product_created"
    static let productViewed = "product_viewed"
    static let productPurchased = "product_purchased"
    static let reviewSubmitted = "review_submitted"
    static let searchPerformed = "search_performed"
    static let categoryViewed = "category_viewed"
    static let profileViewed = "profile_viewed"
    static let messagesSent = "message_sent"
    static let levelUp = "level_up"
    static let achievementUnlocked = "achievement_unlocked"
}

// MARK: - Firebase Remote Config Keys

struct FirebaseRemoteConfigKeys {
    static let maintenanceMode = "maintenance_mode"
    static let minAppVersion = "min_app_version"
    static let maxProductImages = "max_product_images"
    static let maxImageSizeMB = "max_image_size_mb"
    static let featuredProductsLimit = "featured_products_limit"
    static let searchResultsLimit = "search_results_limit"
    static let enableChatFeature = "enable_chat_feature"
    static let enablePushNotifications = "enable_push_notifications"
}