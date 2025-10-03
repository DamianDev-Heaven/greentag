//
//  AuthService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Supabase

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let supabaseManager = SupabaseManager.shared
    private let userDefaults = UserDefaults.standard
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private init() {
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    // MARK: - Authentication Status
    
    func checkAuthenticationStatus() async {
        isLoading = true
        
        do {
            if let session = supabaseManager.client.auth.session {
                let user = try await getUserProfile(userId: session.user.id.uuidString)
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            } else {
                await MainActor.run {
                    self.currentUser = nil
                    self.isAuthenticated = false
                }
            }
        } catch {
            print("Error checking auth status: \(error)")
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    // MARK: - Authentication Methods
    
    func signIn(email: String, password: String) async throws -> User {
        isLoading = true
        defer { Task { @MainActor in self.isLoading = false } }
        
        do {
            let session = try await supabaseManager.client.auth.signIn(
                email: email,
                password: password
            )
            
            let user = try await getUserProfile(userId: session.user.id.uuidString)
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            // Store user ID locally
            userDefaults.set(session.user.id.uuidString, forKey: "user_id")
            
            return user
            
        } catch {
            throw AppError.authentication(error.localizedDescription)
        }
    }
    
    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> User {
        isLoading = true
        defer { Task { @MainActor in self.isLoading = false } }
        
        do {
            let session = try await supabaseManager.client.auth.signUp(
                email: email,
                password: password
            )
            
            // Create user profile in Supabase
            let user = User(
                id: session.user.id.uuidString,
                firstName: firstName,
                lastName: lastName,
                email: email
            )
            
            // Save to Supabase profiles table
            try await createUserProfile(user: user)
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            // Store user ID locally
            userDefaults.set(session.user.id.uuidString, forKey: "user_id")
            
            return user
            
        } catch {
            throw AppError.authentication(error.localizedDescription)
        }
    }
    
    func signOut() async throws {
        isLoading = true
        defer { Task { @MainActor in self.isLoading = false } }
        
        do {
            try await supabaseManager.client.auth.signOut()
            
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
            
            userDefaults.removeObject(forKey: "user_id")
            
        } catch {
            throw AppError.authentication("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await supabaseManager.client.auth.resetPasswordForEmail(email)
        } catch {
            throw AppError.authentication("Error al enviar email de recuperación: \(error.localizedDescription)")
        }
    }
    
    func updatePassword(newPassword: String) async throws {
        do {
            _ = try await supabaseManager.client.auth.update(
                user: UserAttributes(password: newPassword)
            )
        } catch {
            throw AppError.authentication("Error al actualizar contraseña: \(error.localizedDescription)")
        }
    }
    
    func getCurrentUser() async throws -> User? {
        guard let session = supabaseManager.client.auth.session else {
            return nil
        }
        
        return try await getUserProfile(userId: session.user.id.uuidString)
    }
    
    func updateUserProfile(user: User) async throws -> User {
        guard let session = supabaseManager.client.auth.session else {
            throw AppError.authentication("Usuario no autenticado")
        }
        
        do {
            let updatedUser = User(
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                phoneNumber: user.phoneNumber,
                country: user.country,
                city: user.city,
                profileImageURL: user.profileImageURL,
                averageRating: user.averageRating,
                totalReviews: user.totalReviews,
                ecoPoints: user.ecoPoints,
                createdAt: user.createdAt,
                updatedAt: Date(),
                isVerified: user.isVerified
            )
            
            try await supabaseManager.client
                .from("profiles")
                .update(updatedUser)
                .eq("id", value: user.id)
                .execute()
            
            await MainActor.run {
                self.currentUser = updatedUser
            }
            
            return updatedUser
            
        } catch {
            throw AppError.database("Error al actualizar perfil: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        guard let session = supabaseManager.client.auth.session else {
            throw AppError.authentication("Usuario no autenticado")
        }
        
        do {
            // Delete user data from Supabase (handled by CASCADE in database)
            // Delete auth user (this will trigger CASCADE delete in database)
            let response = try await supabaseManager.client.auth.admin.deleteUser(id: session.user.id)
            
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
            
            userDefaults.removeObject(forKey: "user_id")
            
        } catch {
            throw AppError.authentication("Error al eliminar cuenta: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func createUserProfile(user: User) async throws {
        do {
            try await supabaseManager.client
                .from("profiles")
                .insert(user)
                .execute()
        } catch {
            throw AppError.database("Error al crear perfil: \(error.localizedDescription)")
        }
    }
    
    private func getUserProfile(userId: String) async throws -> User {
        do {
            let response: User = try await supabaseManager.client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.database("Error al obtener perfil: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Validation Methods
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = AppConstants.Validation.emailPattern
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= AppConstants.Validation.minPasswordLength
    }
    
    func validateName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Auth State Change Listener

extension AuthService {
    func startAuthStateListener() {
        Task {
            for await authState in supabaseManager.client.auth.authStateChanges {
                await handleAuthStateChange(authState)
            }
        }
    }
    
    private func handleAuthStateChange(_ authState: AuthState) async {
        switch authState.event {
        case .signedIn:
            if let session = authState.session {
                do {
                    let user = try await getUserProfile(userId: session.user.id.uuidString)
                    await MainActor.run {
                        self.currentUser = user
                        self.isAuthenticated = true
                    }
                } catch {
                    print("Error loading user profile: \(error)")
                }
            }
        case .signedOut:
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        case .tokenRefreshed:
            // Token refreshed, no action needed
            break
        case .userUpdated:
            // User updated, refresh profile if needed
            if let session = authState.session {
                do {
                    let user = try await getUserProfile(userId: session.user.id.uuidString)
                    await MainActor.run {
                        self.currentUser = user
                    }
                } catch {
                    print("Error refreshing user profile: \(error)")
                }
            }
        case .passwordRecovery:
            // Password recovery initiated
            break
        }
    }
}