//
//  SupabaseManager.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation
import Supabase

/// Gestor principal de Supabase que maneja la configuración y conexión
/// Implementa el patrón Singleton para acceso global
@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // MARK: - Configuración de Supabase
    private let supabaseURL = "https://twhqxwpkuhawzsgqamqz.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3aHF4d3BrdWhhd3pzZ3FhbXF6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTUyNDMzMiwiZXhwIjoyMDc1MTAwMzMyfQ.pn1oSN1d0w7MA05lsjF1U1e-KRTXXn9wsmogzwNSh2M"
    
    // Cliente de Supabase
    let supabase: SupabaseClient
    
    // MARK: - Estado de autenticación
    @Published var isInitialized = false
    @Published var currentSession: Session?
    
    private init() {
        // Inicializar cliente de Supabase con la configuración
        guard let url = URL(string: supabaseURL) else {
            fatalError("URL de Supabase inválida")
        }
        
        // Configurar cliente con configuraciones optimizadas
        let configuration = SupabaseConfiguration(
            url: url,
            anonKey: supabaseAnonKey,
            db: .init(
                schema: "public"
            ),
            auth: .init(
                autoRefreshToken: true,
                persistSession: true,
                detectSessionInUrl: false
            ),
            global: .init(
                headers: [
                    "apikey": supabaseAnonKey,
                    "Authorization": "Bearer \(supabaseAnonKey)"
                ]
            )
        )
        
        self.supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseAnonKey,
            options: configuration
        )
        
        Task {
            await initialize()
        }
    }
    
    // MARK: - Inicialización
    private func initialize() async {
        do {
            // Recuperar sesión persistente si existe
            let session = try await supabase.auth.session
            await MainActor.run {
                self.currentSession = session
                self.isInitialized = true
            }
            
            // Configurar listener para cambios de autenticación
            setupAuthStateListener()
            
            print("✅ SupabaseManager inicializado correctamente")
        } catch {
            print("❌ Error al inicializar SupabaseManager: \(error.localizedDescription)")
            await MainActor.run {
                self.isInitialized = true
            }
        }
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        Task {
            for await state in supabase.auth.authStateChanges {
                await MainActor.run {
                    switch state {
                    case .signedIn(let session):
                        self.currentSession = session
                        print("✅ Usuario autenticado: \(session.user.email ?? "sin email")")
                        
                    case .signedOut:
                        self.currentSession = nil
                        print("🚪 Usuario cerró sesión")
                        
                    case .passwordRecovery:
                        print("🔑 Recuperación de contraseña iniciada")
                        
                    case .tokenRefreshed(let session):
                        self.currentSession = session
                        print("🔄 Token renovado")
                        
                    case .userUpdated(let user):
                        print("👤 Usuario actualizado: \(user.email ?? "sin email")")
                        
                    case .userDeleted:
                        self.currentSession = nil
                        print("🗑️ Usuario eliminado")
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers de Autenticación
    
    /// Verifica si hay un usuario autenticado
    var isAuthenticated: Bool {
        return currentSession?.user != nil
    }
    
    /// Obtiene el ID del usuario actual
    var currentUserId: String? {
        return currentSession?.user.id.uuidString
    }
    
    /// Obtiene el email del usuario actual
    var currentUserEmail: String? {
        return currentSession?.user.email
    }
    
    // MARK: - Manejo de Errores
    
    /// Convierte errores de Supabase a errores localizados
    func handleSupabaseError(_ error: Error) -> SupabaseError {
        if let postgrestError = error as? PostgrestError {
            switch postgrestError.code {
            case "PGRST116":
                return .notFound
            case "23505":
                return .duplicateEntry
            case "23503":
                return .foreignKeyViolation
            default:
                return .databaseError(postgrestError.message)
            }
        } else if let authError = error as? AuthError {
            switch authError {
            case .weakPassword:
                return .weakPassword
            case .emailAlreadyRegistered:
                return .emailAlreadyExists
            case .invalidCredentials:
                return .invalidCredentials
            default:
                return .authenticationError(authError.localizedDescription)
            }
        } else {
            return .unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Configuración de Storage
    
    /// Configuración para el bucket de imágenes de productos
    func getProductImagesStorageURL() -> String {
        return "\(supabaseURL)/storage/v1/object/public/product-images/"
    }
    
    /// Configuración para el bucket de avatares
    func getAvatarsStorageURL() -> String {
        return "\(supabaseURL)/storage/v1/object/public/avatars/"
    }
}

// MARK: - Custom Errors

enum SupabaseError: LocalizedError {
    case notFound
    case duplicateEntry
    case foreignKeyViolation
    case databaseError(String)
    case authenticationError(String)
    case weakPassword
    case emailAlreadyExists
    case invalidCredentials
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Recurso no encontrado"
        case .duplicateEntry:
            return "El registro ya existe"
        case .foreignKeyViolation:
            return "Error de integridad de datos"
        case .databaseError(let message):
            return "Error de base de datos: \(message)"
        case .authenticationError(let message):
            return "Error de autenticación: \(message)"
        case .weakPassword:
            return "La contraseña debe tener al menos 6 caracteres"
        case .emailAlreadyExists:
            return "Este email ya está registrado"
        case .invalidCredentials:
            return "Email o contraseña incorrectos"
        case .networkError:
            return "Error de conexión. Verifica tu internet"
        case .unknown(let message):
            return "Error inesperado: \(message)"
        }
    }
}

// MARK: - Constants

extension SupabaseManager {
    struct Tables {
        static let profiles = "profiles"
        static let products = "products"
        static let productImages = "product_images"
        static let reviews = "reviews"
        static let shipments = "shipments"
    }
    
    struct StorageBuckets {
        static let productImages = "product-images"
        static let avatars = "avatars"
    }
}