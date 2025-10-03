//
//  Constants.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

// MARK: - App Colors
struct AppColors {
    static let primary = Color("PrimaryColor")
    static let secondary = Color("SecondaryColor")
    static let accent = Color("AccentColor")
    static let background = Color("BackgroundColor")
    static let surface = Color("SurfaceColor")
    static let error = Color("ErrorColor")
    static let warning = Color("WarningColor")
    static let success = Color("SuccessColor")
    static let textPrimary = Color("TextPrimaryColor")
    static let textSecondary = Color("TextSecondaryColor")
    static let cardBackground = Color("CardBackgroundColor")
    static let divider = Color("DividerColor")
}

// MARK: - App Dimensions
struct AppDimensions {
    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    // Corner Radius
    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24
    
    // Button Heights
    static let buttonHeight: CGFloat = 50
    static let buttonHeightS: CGFloat = 40
    static let buttonHeightL: CGFloat = 56
    
    // Text Field Heights
    static let textFieldHeight: CGFloat = 50
    
    // Card Heights
    static let productCardHeight: CGFloat = 200
    static let userCardHeight: CGFloat = 80
    
    // Icon Sizes
    static let iconSizeS: CGFloat = 16
    static let iconSizeM: CGFloat = 24
    static let iconSizeL: CGFloat = 32
    static let iconSizeXL: CGFloat = 48
    
    // Profile Image Sizes
    static let profileImageS: CGFloat = 40
    static let profileImageM: CGFloat = 60
    static let profileImageL: CGFloat = 80
    static let profileImageXL: CGFloat = 120
}

// MARK: - App Fonts
struct AppFonts {
    static let displayLarge = Font.system(size: 32, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 24, weight: .bold, design: .default)
    
    static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .default)
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .default)
    static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .default)
    
    static let titleLarge = Font.system(size: 16, weight: .medium, design: .default)
    static let titleMedium = Font.system(size: 14, weight: .medium, design: .default)
    static let titleSmall = Font.system(size: 12, weight: .medium, design: .default)
    
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 10, weight: .medium, design: .default)
}

// MARK: - App Strings
struct AppStrings {
    // General
    static let appName = "GreenTag"
    static let cancel = "Cancelar"
    static let done = "Hecho"
    static let save = "Guardar"
    static let delete = "Eliminar"
    static let edit = "Editar"
    static let loading = "Cargando..."
    static let retry = "Reintentar"
    static let error = "Error"
    static let success = "Éxito"
    
    // Authentication
    static let login = "Iniciar sesión"
    static let register = "Registrarse"
    static let logout = "Cerrar sesión"
    static let forgotPassword = "¿Olvidaste tu contraseña?"
    static let createAccount = "Crear cuenta"
    static let alreadyHaveAccount = "¿Ya tienes cuenta?"
    
    // Navigation
    static let home = "Inicio"
    static let profile = "Perfil"
    static let rankings = "Rankings"
    static let publish = "Publicar"
    static let search = "Buscar"
    
    // Product
    static let products = "Productos"
    static let addProduct = "Agregar producto"
    static let productDetails = "Detalles del producto"
    static let productDescription = "Descripción"
    static let productPrice = "Precio"
    static let productCondition = "Estado"
    static let productCategory = "Categoría"
    static let productLocation = "Ubicación"
    static let iWantThis = "Lo quiero"
    static let contactSeller = "Contactar vendedor"
    
    // User
    static let userProfile = "Perfil de usuario"
    static let userRating = "Calificación"
    static let userReviews = "Reseñas"
    static let ecoPoints = "Puntos Eco"
    static let memberSince = "Miembro desde"
    
    // Shipment
    static let shipments = "Envíos"
    static let shipmentDetails = "Detalles del envío"
    static let trackingNumber = "Número de seguimiento"
    static let estimatedDelivery = "Entrega estimada"
    
    // Error Messages
    static let genericError = "Ha ocurrido un error. Intenta nuevamente."
    static let networkError = "Error de conexión. Verifica tu internet."
    static let validationError = "Por favor, completa todos los campos requeridos."
}

// MARK: - App Configuration
struct AppConfig {
    static let maxImageUploadSize = 5 * 1024 * 1024 // 5MB
    static let maxImagesPerProduct = 5
    static let imageCompressionQuality: CGFloat = 0.8
    static let defaultAnimationDuration: Double = 0.3
    static let longAnimationDuration: Double = 0.5
    static let apiTimeout: TimeInterval = 30
    static let cacheExpirationTime: TimeInterval = 3600 // 1 hour
}

// MARK: - App URLs
struct AppURLs {
    static let privacyPolicy = "https://greentag.app/privacy"
    static let termsOfService = "https://greentag.app/terms"
    static let support = "https://greentag.app/support"
    static let website = "https://greentag.app"
}

// MARK: - Notification Names
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let productWasCreated = Notification.Name("productWasCreated")
    static let productWasUpdated = Notification.Name("productWasUpdated")
    static let ecoPointsDidUpdate = Notification.Name("ecoPointsDidUpdate")
}

// MARK: - UserDefaults Keys
struct UserDefaultsKeys {
    static let currentUser = "currentUser"
    static let authToken = "auth_token"
    static let hasSeenOnboarding = "hasSeenOnboarding"
    static let preferredLanguage = "preferredLanguage"
    static let notificationsEnabled = "notificationsEnabled"
    static let locationPermissionAsked = "locationPermissionAsked"
}

// MARK: - Animation Constants
struct AppAnimations {
    static let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let easeInOut = Animation.easeInOut(duration: 0.3)
    static let bouncy = Animation.interpolatingSpring(stiffness: 300, damping: 30)
}

// MARK: - Haptic Feedback
enum HapticFeedback {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    
    func trigger() {
        switch self {
        case .light:
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        case .medium:
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        case .heavy:
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        case .success:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        case .warning:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.warning)
        case .error:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
        }
    }
}