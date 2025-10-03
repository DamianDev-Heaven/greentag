//
//  FirebaseManager.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let auth = Auth.auth()
    
    private init() {
        configureFirestore()
    }
    
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
    
    // MARK: - Authentication Helper
    
    var currentUserId: String? {
        return auth.currentUser?.uid
    }
    
    var isAuthenticated: Bool {
        return auth.currentUser != nil
    }
    
    // MARK: - Firestore Methods
    
    func create<T: Codable>(
        collection: String,
        document: String? = nil,
        data: T
    ) async throws -> String {
        let collectionRef = db.collection(collection)
        let docRef = document != nil ? collectionRef.document(document!) : collectionRef.document()
        
        do {
            let encoder = Firestore.Encoder()
            let encodedData = try encoder.encode(data)
            try await docRef.setData(encodedData)
            return docRef.documentID
        } catch {
            throw FirebaseError.writeError(error)
        }
    }
    
    func read<T: Codable>(
        collection: String,
        document: String,
        type: T.Type
    ) async throws -> T {
        let docRef = db.collection(collection).document(document)
        
        do {
            let snapshot = try await docRef.getDocument()
            
            guard snapshot.exists else {
                throw FirebaseError.documentNotFound
            }
            
            guard let data = snapshot.data() else {
                throw FirebaseError.invalidData
            }
            
            let decoder = Firestore.Decoder()
            var decodedData = try decoder.decode(type, from: data)
            
            // Add document ID if the model supports it
            if var identifiable = decodedData as? IdentifiableModel {
                identifiable.id = snapshot.documentID
                decodedData = identifiable as! T
            }
            
            return decodedData
        } catch {
            if error is FirebaseError {
                throw error
            }
            throw FirebaseError.readError(error)
        }
    }
    
    func update<T: Codable>(
        collection: String,
        document: String,
        data: T,
        merge: Bool = true
    ) async throws {
        let docRef = db.collection(collection).document(document)
        
        do {
            let encoder = Firestore.Encoder()
            let encodedData = try encoder.encode(data)
            
            if merge {
                try await docRef.setData(encodedData, merge: true)
            } else {
                try await docRef.updateData(encodedData)
            }
        } catch {
            throw FirebaseError.updateError(error)
        }
    }
    
    func updateFields(
        collection: String,
        document: String,
        fields: [String: Any]
    ) async throws {
        let docRef = db.collection(collection).document(document)
        
        do {
            try await docRef.updateData(fields)
        } catch {
            throw FirebaseError.updateError(error)
        }
    }
    
    func delete(collection: String, document: String) async throws {
        let docRef = db.collection(collection).document(document)
        
        do {
            try await docRef.delete()
        } catch {
            throw FirebaseError.deleteError(error)
        }
    }
    
    func query<T: Codable>(
        collection: String,
        whereField: String? = nil,
        isEqualTo: Any? = nil,
        isGreaterThan: Any? = nil,
        isLessThan: Any? = nil,
        whereFieldArray: String? = nil,
        arrayContains: Any? = nil,
        orderBy: String? = nil,
        descending: Bool = false,
        limit: Int? = nil,
        type: T.Type
    ) async throws -> [T] {
        var query: Query = db.collection(collection)
        
        // Add where clauses
        if let field = whereField, let value = isEqualTo {
            query = query.whereField(field, isEqualTo: value)
        }
        
        if let field = whereField, let value = isGreaterThan {
            query = query.whereField(field, isGreaterThan: value)
        }
        
        if let field = whereField, let value = isLessThan {
            query = query.whereField(field, isLessThan: value)
        }
        
        // Add array contains clause
        if let field = whereFieldArray, let value = arrayContains {
            query = query.whereField(field, arrayContains: value)
        }
        
        // Add order by
        if let orderField = orderBy {
            query = query.order(by: orderField, descending: descending)
        }
        
        // Add limit
        if let limitCount = limit {
            query = query.limit(to: limitCount)
        }
        
        do {
            let snapshot = try await query.getDocuments()
            let decoder = Firestore.Decoder()
            
            return try snapshot.documents.compactMap { document in
                var data = document.data()
                data["id"] = document.documentID
                return try decoder.decode(type, from: data)
            }
        } catch {
            throw FirebaseError.queryError(error)
        }
    }
    
    func listenToDocument<T: Codable>(
        collection: String,
        document: String,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> ListenerRegistration {
        let docRef = db.collection(collection).document(document)
        
        return docRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(FirebaseError.listenerError(error)))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(FirebaseError.documentNotFound))
                return
            }
            
            guard let data = snapshot.data() else {
                completion(.failure(FirebaseError.invalidData))
                return
            }
            
            do {
                let decoder = Firestore.Decoder()
                var result = try decoder.decode(type, from: data)
                
                // Add document ID if the model supports it
                if var identifiable = result as? IdentifiableModel {
                    identifiable.id = snapshot.documentID
                    result = identifiable as! T
                }
                
                completion(.success(result))
            } catch {
                completion(.failure(FirebaseError.decodingError(error)))
            }
        }
    }
    
    func listenToCollection<T: Codable>(
        collection: String,
        whereField: String? = nil,
        isEqualTo: Any? = nil,
        orderBy: String? = nil,
        descending: Bool = false,
        limit: Int? = nil,
        type: T.Type,
        completion: @escaping (Result<[T], Error>) -> Void
    ) -> ListenerRegistration {
        var query: Query = db.collection(collection)
        
        // Add where clause
        if let field = whereField, let value = isEqualTo {
            query = query.whereField(field, isEqualTo: value)
        }
        
        // Add order by
        if let orderField = orderBy {
            query = query.order(by: orderField, descending: descending)
        }
        
        // Add limit
        if let limitCount = limit {
            query = query.limit(to: limitCount)
        }
        
        return query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(FirebaseError.listenerError(error)))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(FirebaseError.invalidData))
                return
            }
            
            do {
                let decoder = Firestore.Decoder()
                let results = try snapshot.documents.compactMap { document in
                    var data = document.data()
                    data["id"] = document.documentID
                    return try decoder.decode(type, from: data)
                }
                completion(.success(results))
            } catch {
                completion(.failure(FirebaseError.decodingError(error)))
            }
        }
    }
    
    // MARK: - Storage Methods
    
    func uploadImage(
        data: Data,
        path: String,
        contentType: String = "image/jpeg"
    ) async throws -> String {
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        do {
            let _ = try await storageRef.putDataAsync(data, metadata: metadata)
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            throw FirebaseError.uploadError(error)
        }
    }
    
    func uploadMultipleImages(
        imagesData: [Data],
        basePath: String,
        contentType: String = "image/jpeg"
    ) async throws -> [String] {
        var uploadedURLs: [String] = []
        
        for (index, imageData) in imagesData.enumerated() {
            let imagePath = "\(basePath)/image_\(index)_\(UUID().uuidString).jpg"
            let url = try await uploadImage(data: imageData, path: imagePath, contentType: contentType)
            uploadedURLs.append(url)
        }
        
        return uploadedURLs
    }
    
    func deleteImage(path: String) async throws {
        let storageRef = storage.reference().child(path)
        
        do {
            try await storageRef.delete()
        } catch {
            throw FirebaseError.deleteError(error)
        }
    }
    
    func downloadImage(url: String) async throws -> Data {
        guard let downloadURL = URL(string: url) else {
            throw FirebaseError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: downloadURL)
            return data
        } catch {
            throw FirebaseError.downloadError(error)
        }
    }
    
    // MARK: - Batch Operations
    
    func batchWrite(operations: [(collection: String, document: String, data: [String: Any])]) async throws {
        let batch = db.batch()
        
        for operation in operations {
            let docRef = db.collection(operation.collection).document(operation.document)
            batch.setData(operation.data, forDocument: docRef)
        }
        
        do {
            try await batch.commit()
        } catch {
            throw FirebaseError.writeError(error)
        }
    }
    
    // MARK: - Search Methods
    
    func searchProducts(query: String, limit: Int = 20) async throws -> [Product] {
        // Simple text search implementation
        // For better search, consider using Algolia or Elasticsearch
        let lowercaseQuery = query.lowercased()
        
        do {
            let snapshot = try await db.collection(FirebaseCollections.products)
                .whereField("searchTerms", arrayContains: lowercaseQuery)
                .limit(to: limit)
                .getDocuments()
            
            let decoder = Firestore.Decoder()
            return try snapshot.documents.compactMap { document in
                var data = document.data()
                data["id"] = document.documentID
                return try decoder.decode(Product.self, from: data)
            }
        } catch {
            throw FirebaseError.queryError(error)
        }
    }
}

// MARK: - Supporting Types

protocol IdentifiableModel {
    var id: String? { get set }
}

enum FirebaseError: LocalizedError {
    case writeError(Error)
    case readError(Error)
    case updateError(Error)
    case deleteError(Error)
    case queryError(Error)
    case uploadError(Error)
    case downloadError(Error)
    case listenerError(Error)
    case decodingError(Error)
    case documentNotFound
    case invalidData
    case invalidURL
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .writeError(let error):
            return "Error al escribir datos: \(error.localizedDescription)"
        case .readError(let error):
            return "Error al leer datos: \(error.localizedDescription)"
        case .updateError(let error):
            return "Error al actualizar datos: \(error.localizedDescription)"
        case .deleteError(let error):
            return "Error al eliminar datos: \(error.localizedDescription)"
        case .queryError(let error):
            return "Error en la consulta: \(error.localizedDescription)"
        case .uploadError(let error):
            return "Error al subir archivo: \(error.localizedDescription)"
        case .downloadError(let error):
            return "Error al descargar archivo: \(error.localizedDescription)"
        case .listenerError(let error):
            return "Error en el listener: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Error al procesar datos: \(error.localizedDescription)"
        case .documentNotFound:
            return "Documento no encontrado"
        case .invalidData:
            return "Datos inválidos"
        case .invalidURL:
            return "URL inválida"
        case .unauthorized:
            return "No autorizado"
        }
    }
}

// MARK: - Firebase Collections
struct FirebaseCollections {
    static let users = "users"
    static let products = "products"
    static let reviews = "reviews"
    static let shipments = "shipments"
    static let rankings = "rankings"
    static let conversations = "conversations"
    static let messages = "messages"
    static let categories = "categories"
    static let notifications = "notifications"
}

// MARK: - Firebase Storage Paths
struct FirebaseStoragePaths {
    static let userProfiles = "user_profiles"
    static let productImages = "product_images"
    static let reviewImages = "review_images"
    
    static func userProfilePath(userId: String) -> String {
        return "\(userProfiles)/\(userId)"
    }
    
    static func productImagesPath(productId: String) -> String {
        return "\(productImages)/\(productId)"
    }
    
    static func reviewImagesPath(reviewId: String) -> String {
        return "\(reviewImages)/\(reviewId)"
    }
}