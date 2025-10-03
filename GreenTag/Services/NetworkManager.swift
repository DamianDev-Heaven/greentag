//
//  NetworkManager.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.greentag.app/v1" // Replace with actual API URL
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Generic Request Method
    
    func request(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) async throws -> Data {
        
        guard let url = buildURL(endpoint: endpoint, parameters: method == .GET ? parameters : nil) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token if available
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body for POST/PUT requests
        if let body = body {
            request.httpBody = body
        } else if method != .GET, let parameters = parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            try validateResponse(httpResponse, data: data)
            
            return data
            
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.networkError(error)
            }
        }
    }
    
    // MARK: - Specialized Methods
    
    func get(endpoint: String, parameters: [String: Any]? = nil) async throws -> Data {
        return try await request(endpoint: endpoint, method: .GET, parameters: parameters)
    }
    
    func post(endpoint: String, parameters: [String: Any]? = nil) async throws -> Data {
        return try await request(endpoint: endpoint, method: .POST, parameters: parameters)
    }
    
    func put(endpoint: String, parameters: [String: Any]? = nil) async throws -> Data {
        return try await request(endpoint: endpoint, method: .PUT, parameters: parameters)
    }
    
    func delete(endpoint: String) async throws -> Data {
        return try await request(endpoint: endpoint, method: .DELETE)
    }
    
    // MARK: - Image Upload
    
    func uploadImage(imageData: Data, endpoint: String, fieldName: String = "image") async throws -> Data {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body = createMultipartBody(imageData: imageData, boundary: boundary, fieldName: fieldName)
        request.httpBody = body
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            try validateResponse(httpResponse, data: data)
            
            return data
            
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.networkError(error)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func buildURL(endpoint: String, parameters: [String: Any]?) -> URL? {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            return nil
        }
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        return urlComponents.url
    }
    
    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 400:
            throw NetworkError.badRequest
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 422:
            if let errorResponse = try? JSONDecoder().decode(ValidationErrorResponse.self, from: data) {
                throw NetworkError.validationError(errorResponse.message)
            }
            throw NetworkError.validationError("Datos inválidos")
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.unknownError(response.statusCode)
        }
    }
    
    private func createMultipartBody(imageData: Data, boundary: String, fieldName: String) -> Data {
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    private func getAuthToken() -> String? {
        // In a real app, retrieve token from Keychain or UserDefaults
        return UserDefaults.standard.string(forKey: "auth_token")
    }
    
    func setAuthToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
    }
    
    func clearAuthToken() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
    }
}

// MARK: - HTTP Methods

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case validationError(String)
    case serverError
    case networkError(Error)
    case unknownError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .badRequest:
            return "Solicitud incorrecta"
        case .unauthorized:
            return "No autorizado. Por favor, inicia sesión nuevamente"
        case .forbidden:
            return "Acceso prohibido"
        case .notFound:
            return "Recurso no encontrado"
        case .validationError(let message):
            return message
        case .serverError:
            return "Error del servidor. Intenta más tarde"
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        case .unknownError(let statusCode):
            return "Error desconocido (código: \(statusCode))"
        }
    }
}

// MARK: - Response Models

struct ValidationErrorResponse: Codable {
    let message: String
    let errors: [String: [String]]?
}

struct APIResponse<T: Codable>: Codable {
    let data: T
    let message: String?
    let success: Bool
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
}