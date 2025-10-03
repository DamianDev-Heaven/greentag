//
//  AuthService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    
    private let firebaseManager = FirebaseManager.shared
    private let auth = Auth.auth()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let user = try await getUserFromFirestore(uid: authResult.user.uid)
            
            // Store user ID locally
            userDefaults.set(authResult.user.uid, forKey: "user_id")
            
            return user
            
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func signUp(name: String, email: String, password: String) async throws -> User {
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            // Create user profile in Firestore
            let user = User(
                id: authResult.user.uid,
                name: name,
                email: email,
                profileImageURL: nil,
                bio: nil,
                location: nil,
                phone: nil,
                points: 0,
                level: .beginner,
                joinDate: Date(),
                averageRating: 0.0,
                totalReviews: 0,
                totalSales: 0,
                totalPurchases: 0,
                isVerified: false,
                lastActiveDate: Date(),
                favoriteCategories: [],
                sustainabilityGoals: []
            )
            
            // Save to Firestore
            try await firebaseManager.create(
                collection: FirebaseCollections.users,
                document: authResult.user.uid,
                data: user
            )
            
            // Update Firebase Auth profile
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // Store user ID locally
            userDefaults.set(authResult.user.uid, forKey: "user_id")
            
            return user
            
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            userDefaults.removeObject(forKey: "user_id")
        } catch {
            throw AuthError.signOutFailed(error.localizedDescription)
        }
    }
    
    func getCurrentUser() async throws -> User? {
        guard let currentUser = auth.currentUser else {
            return nil
        }
        
        do {
            return try await getUserFromFirestore(uid: currentUser.uid)
        } catch {
            throw AuthError.userFetchFailed(error.localizedDescription)
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func updateProfile(user: User) async throws -> User {
        guard let currentUser = auth.currentUser else {
            throw AuthError.notAuthenticated
        }
        
        do {
            // Update Firebase Auth profile if name changed
            if currentUser.displayName != user.name {
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.displayName = user.name
                try await changeRequest.commitChanges()
            }
            
            // Update Firestore document
            var updatedUser = user
            updatedUser.lastActiveDate = Date()
            
            try await firebaseManager.update(
                collection: FirebaseCollections.users,
                document: currentUser.uid,
                data: updatedUser
            )
            
            return updatedUser
            
        } catch {
            throw AuthError.profileUpdateFailed(error.localizedDescription)
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let currentUser = auth.currentUser else {
            throw AuthError.notAuthenticated
        }
        
        do {
            // Re-authenticate user
            let credential = EmailAuthProvider.credential(withEmail: currentUser.email ?? "", password: currentPassword)
            try await currentUser.reauthenticate(with: credential)
            
            // Update password
            try await currentUser.updatePassword(to: newPassword)
            
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func deleteAccount(password: String) async throws {
        guard let currentUser = auth.currentUser else {
            throw AuthError.notAuthenticated
        }
        
        do {
            // Re-authenticate user
            let credential = EmailAuthProvider.credential(withEmail: currentUser.email ?? "", password: password)
            try await currentUser.reauthenticate(with: credential)
            
            // Delete user data from Firestore
            try await firebaseManager.delete(
                collection: FirebaseCollections.users,
                document: currentUser.uid
            )
            
            // Delete user profile image if exists
            try? await firebaseManager.deleteImage(
                path: FirebaseStoragePaths.userProfilePath(userId: currentUser.uid)
            )
            
            // Delete Firebase Auth account
            try await currentUser.delete()
            
            // Clear local storage
            userDefaults.removeObject(forKey: "user_id")
            
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    var isAuthenticated: Bool {
        return auth.currentUser != nil
    }
    
    var isEmailVerified: Bool {
        return auth.currentUser?.isEmailVerified ?? false
    }
    
    var currentUserUID: String? {
        return auth.currentUser?.uid
    }
    
    private func getUserFromFirestore(uid: String) async throws -> User {
        return try await firebaseManager.read(
            collection: FirebaseCollections.users,
            document: uid,
            type: User.self
        )
    }
    
    private func mapAuthError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
            return AuthError.unknown(error.localizedDescription)
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .userNotFound:
            return .userNotFound
        case .wrongPassword:
            return .wrongPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        case .tooManyRequests:
            return .tooManyRequests
        case .userDisabled:
            return .userDisabled
        case .requiresRecentLogin:
            return .requiresRecentLogin
        default:
            return .unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Auth State Listener
    
    func addAuthStateListener(completion: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            
            if let firebaseUser = firebaseUser {
                Task {
                    do {
                        let user = try await self.getUserFromFirestore(uid: firebaseUser.uid)
                        await MainActor.run {
                            completion(user)
                        }
                    } catch {
                        await MainActor.run {
                            completion(nil)
                        }
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        auth.removeStateDidChangeListener(handle)
    }
}

// MARK: - Supporting Types

enum AuthError: LocalizedError {
    case invalidEmail
    case userNotFound
    case wrongPassword
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case tooManyRequests
    case userDisabled
    case requiresRecentLogin
    case notAuthenticated
    case signOutFailed(String)
    case userFetchFailed(String)
    case profileUpdateFailed(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "El formato del email es inválido"
        case .userNotFound:
            return "No se encontró una cuenta con este email"
        case .wrongPassword:
            return "La contraseña es incorrecta"
        case .emailAlreadyInUse:
            return "Ya existe una cuenta con este email"
        case .weakPassword:
            return "La contraseña debe tener al menos 6 caracteres"
        case .networkError:
            return "Error de conexión. Verifica tu internet"
        case .tooManyRequests:
            return "Demasiados intentos. Intenta más tarde"
        case .userDisabled:
            return "Esta cuenta ha sido deshabilitada"
        case .requiresRecentLogin:
            return "Necesitas iniciar sesión nuevamente"
        case .notAuthenticated:
            return "No has iniciado sesión"
        case .signOutFailed(let message):
            return "Error al cerrar sesión: \(message)"
        case .userFetchFailed(let message):
            return "Error al obtener usuario: \(message)"
        case .profileUpdateFailed(let message):
            return "Error al actualizar perfil: \(message)"
        case .unknown(let message):
            return "Error desconocido: \(message)"
        }
    }
}

// MARK: - Response Models

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}