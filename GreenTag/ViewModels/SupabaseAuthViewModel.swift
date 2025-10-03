//
//  AuthViewModel.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var loadingState: LoadingState = .idle
    @Published var errorMessage: String?
    
    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var country = ""
    @Published var city = ""
    
    // Form validation
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    @Published var firstNameError: String?
    @Published var lastNameError: String?
    
    private let authService = SupabaseAuthService.shared
    
    init() {
        setupAuthStateListener()
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Methods
    
    func signIn() async {
        guard validateSignInForm() else { return }
        
        isLoading = true
        loadingState = .loading
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            
            currentUser = user
            isAuthenticated = true
            loadingState = .success
            
            // Clear form
            clearForm()
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func signUp() async {
        guard validateSignUpForm() else { return }
        
        isLoading = true
        loadingState = .loading
        errorMessage = nil
        
        do {
            let user = try await authService.signUp(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            
            currentUser = user
            isAuthenticated = true
            loadingState = .success
            
            // Clear form
            clearForm()
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signOut()
            
            currentUser = nil
            isAuthenticated = false
            loadingState = .idle
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func resetPassword() async {
        guard validateEmail(email) else {
            emailError = "Email inválido"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.resetPassword(email: email)
            
            errorMessage = "Se ha enviado un email de recuperación"
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async {
        guard validatePassword(newPassword) else {
            passwordError = "La contraseña debe tener al menos \(AppConstants.Validation.minPasswordLength) caracteres"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.updatePassword(newPassword: newPassword)
            
            errorMessage = "Contraseña actualizada correctamente"
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func updateProfile(user: User) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedUser = try await authService.updateUserProfile(user: user)
            
            currentUser = updatedUser
            errorMessage = "Perfil actualizado correctamente"
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.deleteAccount()
            
            currentUser = nil
            isAuthenticated = false
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func setupAuthStateListener() {
        authService.startAuthStateListener()
        
        // Observe auth service changes
        authService.$currentUser
            .assign(to: &$currentUser)
        
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        authService.$isLoading
            .assign(to: &$isLoading)
    }
    
    private func checkAuthenticationStatus() {
        Task {
            await authService.checkAuthenticationStatus()
        }
    }
    
    private func handleError(_ error: Error) {
        if let appError = error as? AppError {
            errorMessage = appError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        loadingState = .failure(errorMessage ?? "Error desconocido")
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
        phoneNumber = ""
        country = ""
        city = ""
        clearErrors()
    }
    
    private func clearErrors() {
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        firstNameError = nil
        lastNameError = nil
        errorMessage = nil
    }
    
    // MARK: - Validation Methods
    
    private func validateSignInForm() -> Bool {
        clearErrors()
        
        var isValid = true
        
        if !validateEmail(email) {
            emailError = "Email inválido"
            isValid = false
        }
        
        if !validatePassword(password) {
            passwordError = "La contraseña debe tener al menos \(AppConstants.Validation.minPasswordLength) caracteres"
            isValid = false
        }
        
        return isValid
    }
    
    private func validateSignUpForm() -> Bool {
        clearErrors()
        
        var isValid = true
        
        if !validateName(firstName) {
            firstNameError = "El nombre es requerido"
            isValid = false
        }
        
        if !validateName(lastName) {
            lastNameError = "El apellido es requerido"
            isValid = false
        }
        
        if !validateEmail(email) {
            emailError = "Email inválido"
            isValid = false
        }
        
        if !validatePassword(password) {
            passwordError = "La contraseña debe tener al menos \(AppConstants.Validation.minPasswordLength) caracteres"
            isValid = false
        }
        
        if password != confirmPassword {
            confirmPasswordError = "Las contraseñas no coinciden"
            isValid = false
        }
        
        return isValid
    }
    
    private func validateEmail(_ email: String) -> Bool {
        return authService.validateEmail(email)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        return authService.validatePassword(password)
    }
    
    private func validateName(_ name: String) -> Bool {
        return authService.validateName(name)
    }
    
    private func validatePhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = AppConstants.Validation.phoneNumberPattern
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    // MARK: - Computed Properties
    
    var isSignInValid: Bool {
        !email.isEmpty && !password.isEmpty && 
        validateEmail(email) && validatePassword(password)
    }
    
    var isSignUpValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty &&
        !email.isEmpty && !password.isEmpty &&
        !confirmPassword.isEmpty && password == confirmPassword &&
        validateName(firstName) && validateName(lastName) &&
        validateEmail(email) && validatePassword(password)
    }
    
    var hasError: Bool {
        emailError != nil || passwordError != nil || 
        confirmPasswordError != nil || firstNameError != nil ||
        lastNameError != nil || errorMessage != nil
    }
    
    var userDisplayName: String {
        currentUser?.fullName ?? "Usuario"
    }
    
    var userInitials: String {
        guard let user = currentUser else { return "U" }
        let firstInitial = String(user.firstName.prefix(1)).uppercased()
        let lastInitial = String(user.lastName.prefix(1)).uppercased()
        return firstInitial + lastInitial
    }
    
    // MARK: - Helper Methods
    
    func prepareProfileForUpdate() -> User? {
        guard let currentUser = currentUser else { return nil }
        
        return User(
            id: currentUser.id,
            firstName: firstName.isEmpty ? currentUser.firstName : firstName,
            lastName: lastName.isEmpty ? currentUser.lastName : lastName,
            email: currentUser.email, // Email cannot be changed here
            phoneNumber: phoneNumber.isEmpty ? currentUser.phoneNumber : phoneNumber,
            country: country.isEmpty ? currentUser.country : country,
            city: city.isEmpty ? currentUser.city : city,
            profileImageURL: currentUser.profileImageURL,
            averageRating: currentUser.averageRating,
            totalReviews: currentUser.totalReviews,
            ecoPoints: currentUser.ecoPoints,
            createdAt: currentUser.createdAt,
            updatedAt: Date(),
            isVerified: currentUser.isVerified
        )
    }
    
    func loadCurrentUserData() {
        guard let user = currentUser else { return }
        
        firstName = user.firstName
        lastName = user.lastName
        email = user.email
        phoneNumber = user.phoneNumber ?? ""
        country = user.country ?? ""
        city = user.city ?? ""
    }
    
    func refreshCurrentUser() async {
        do {
            if let user = try await authService.getCurrentUser() {
                currentUser = user
            }
        } catch {
            handleError(error)
        }
    }
}