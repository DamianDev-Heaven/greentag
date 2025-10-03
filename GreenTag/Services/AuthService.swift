//
//  AuthService.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

class AuthService {
    private let networkManager = NetworkManager.shared
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async throws -> User {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        // For now, return mock data. Replace with actual API call
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        
        // Mock authentication - replace with actual API integration
        if email == "demo@greentag.com" && password == "demo123" {
            return User(
                firstName: "Usuario",
                lastName: "Demo",
                email: email,
                phoneNumber: "+34 123 456 789",
                country: "España",
                city: "Madrid",
                averageRating: 4.5,
                totalReviews: 10,
                ecoPoints: 1500,
                isVerified: true
            )
        }
        
        // Simulate API call
        // let response = try await networkManager.request(
        //     endpoint: "/auth/login",
        //     method: .POST,
        //     parameters: parameters
        // )
        // return try JSONDecoder().decode(User.self, from: response)
        
        throw AuthError.invalidCredentials
    }
    
    func register(
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        country: String,
        city: String,
        password: String
    ) async throws -> User {
        let parameters = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phoneNumber": phoneNumber,
            "country": country,
            "city": city,
            "password": password
        ]
        
        // For now, return mock data. Replace with actual API call
        try await Task.sleep(nanoseconds: 1_500_000_000) // Simulate network delay
        
        // Mock registration - replace with actual API integration
        let newUser = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            country: country,
            city: city
        )
        
        // Simulate API call
        // let response = try await networkManager.request(
        //     endpoint: "/auth/register",
        //     method: .POST,
        //     parameters: parameters
        // )
        // return try JSONDecoder().decode(User.self, from: response)
        
        return newUser
    }
    
    func logout() async throws {
        // Simulate API call to invalidate session
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // let _ = try await networkManager.request(
        //     endpoint: "/auth/logout",
        //     method: .POST
        // )
    }
    
    func refreshToken() async throws -> String {
        // Simulate token refresh
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // let response = try await networkManager.request(
        //     endpoint: "/auth/refresh",
        //     method: .POST
        // )
        // let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: response)
        // return tokenResponse.accessToken
        
        return "mock_refreshed_token"
    }
    
    func resetPassword(email: String) async throws {
        let parameters = ["email": email]
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // let _ = try await networkManager.request(
        //     endpoint: "/auth/reset-password",
        //     method: .POST,
        //     parameters: parameters
        // )
    }
    
    func verifyEmail(code: String) async throws {
        let parameters = ["code": code]
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // let _ = try await networkManager.request(
        //     endpoint: "/auth/verify-email",
        //     method: .POST,
        //     parameters: parameters
        // )
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case weakPassword
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email o contraseña incorrectos"
        case .userNotFound:
            return "Usuario no encontrado"
        case .emailAlreadyExists:
            return "Este email ya está registrado"
        case .weakPassword:
            return "La contraseña debe tener al menos 6 caracteres"
        case .networkError:
            return "Error de conexión. Verifica tu internet"
        case .unknownError:
            return "Ha ocurrido un error inesperado"
        }
    }
}

// MARK: - Response Models

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}