//
//  AuthViewModel.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Registration form
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var country = ""
    @Published var city = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    // Login form
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    
    private let authService = AuthService()
    
    init() {
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        // Check if user is already logged in (from UserDefaults, Keychain, etc.)
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func login() async {
        guard !loginEmail.isEmpty, !loginPassword.isEmpty else {
            errorMessage = "Por favor, completa todos los campos"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.login(email: loginEmail, password: loginPassword)
            self.currentUser = user
            self.isAuthenticated = true
            
            // Save user data locally
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
            
            clearLoginForm()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func register() async {
        guard validateRegistrationForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: phoneNumber,
                country: country,
                city: city,
                password: password
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            
            // Save user data locally
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "currentUser")
            }
            
            clearRegistrationForm()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "currentUser")
        clearAllForms()
    }
    
    private func validateRegistrationForm() -> Bool {
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || 
           phoneNumber.isEmpty || country.isEmpty || city.isEmpty || 
           password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Por favor, completa todos los campos"
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "Por favor, introduce un email válido"
            return false
        }
        
        if password.count < 6 {
            errorMessage = "La contraseña debe tener al menos 6 caracteres"
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Las contraseñas no coinciden"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func clearLoginForm() {
        loginEmail = ""
        loginPassword = ""
    }
    
    private func clearRegistrationForm() {
        firstName = ""
        lastName = ""
        email = ""
        phoneNumber = ""
        country = ""
        city = ""
        password = ""
        confirmPassword = ""
    }
    
    private func clearAllForms() {
        clearLoginForm()
        clearRegistrationForm()
    }
}