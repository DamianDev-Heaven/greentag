//
//  Helpers.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation
import CoreLocation

// MARK: - Validation Helpers
struct ValidationHelper {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[+]?[0-9\\s\\-\\(\\)]{10,}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    static func validateProductForm(
        title: String,
        description: String,
        images: [UIImage],
        isDonation: Bool,
        price: String,
        address: String,
        city: String,
        country: String
    ) -> (isValid: Bool, error: String?) {
        
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return (false, "El título es obligatorio")
        }
        
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return (false, "La descripción es obligatoria")
        }
        
        if images.isEmpty {
            return (false, "Debes agregar al menos una imagen")
        }
        
        if !isDonation && (price.isEmpty || Double(price) == nil || Double(price)! <= 0) {
            return (false, "Debes introducir un precio válido")
        }
        
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return (false, "La dirección es obligatoria")
        }
        
        if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return (false, "La ciudad es obligatoria")
        }
        
        if country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return (false, "El país es obligatorio")
        }
        
        return (true, nil)
    }
}

// MARK: - Format Helpers
struct FormatHelper {
    static func formatPrice(_ price: Double?, isDonation: Bool) -> String {
        if isDonation {
            return "Gratis"
        } else if let price = price {
            return String(format: "%.2f €", price)
        } else {
            return "Precio a consultar"
        }
    }
    
    static func formatRating(_ rating: Double) -> String {
        return String(format: "%.1f", rating)
    }
    
    static func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    static func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    static func formatTimeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    static func formatPhoneNumber(_ phone: String) -> String {
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleaned.hasPrefix("34") && cleaned.count == 11 {
            // Spanish phone number format
            let index1 = cleaned.index(cleaned.startIndex, offsetBy: 2)
            let index2 = cleaned.index(cleaned.startIndex, offsetBy: 5)
            let index3 = cleaned.index(cleaned.startIndex, offsetBy: 8)
            
            return "+34 \(cleaned[index1..<index2]) \(cleaned[index2..<index3]) \(cleaned[index3...])"
        }
        
        return phone
    }
}

// MARK: - Image Helpers
struct ImageHelper {
    static func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    static func compressImage(_ image: UIImage, quality: CGFloat = 0.8) -> UIImage {
        guard let data = image.jpegData(compressionQuality: quality),
              let compressedImage = UIImage(data: data) else {
            return image
        }
        return compressedImage
    }
    
    static func createPlaceholderImage(size: CGSize, text: String = "📷") -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.width * 0.3),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.systemGray3
            ]
            
            let textRect = CGRect(
                x: 0,
                y: (size.height - size.width * 0.3) / 2,
                width: size.width,
                height: size.width * 0.3
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

// MARK: - Location Helpers
struct LocationHelper {
    static func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        return from.distance(from: to)
    }
    
    static func formatAddress(_ address: String, _ city: String, _ country: String) -> String {
        return "\(address), \(city), \(country)"
    }
    
    static func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }
}

// MARK: - Notification Helpers
struct NotificationHelper {
    static func scheduleLocalNotification(
        title: String,
        body: String,
        identifier: String,
        timeInterval: TimeInterval
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

// MARK: - Sharing Helpers
struct SharingHelper {
    static func shareProduct(_ product: Product) -> [Any] {
        var items: [Any] = []
        
        let text = "¡Mira este producto en GreenTag! \(product.title) - \(product.formattedPrice)"
        items.append(text)
        
        if let url = URL(string: "https://greentag.app/product/\(product.id)") {
            items.append(url)
        }
        
        return items
    }
    
    static func shareApp() -> [Any] {
        let text = "¡Descarga GreenTag, la app de marketplace ecológico!"
        let url = URL(string: "https://greentag.app")!
        return [text, url]
    }
}

// MARK: - Color Helpers
struct ColorHelper {
    static func colorForCategory(_ category: ProductCategory) -> Color {
        switch category {
        case .electronics: return .blue
        case .clothing: return .pink
        case .furniture: return .brown
        case .books: return .orange
        case .toys: return .purple
        case .kitchen: return .red
        case .sports: return .green
        case .garden: return .mint
        case .decoration: return .indigo
        case .other: return .gray
        }
    }
    
    static func colorForCondition(_ condition: ProductCondition) -> Color {
        switch condition {
        case .new: return .green
        case .excellent: return .blue
        case .good: return .orange
        case .fair: return .yellow
        case .poor: return .red
        }
    }
    
    static func colorForShipmentStatus(_ status: ShipmentStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .shipped: return .purple
        case .inTransit: return .indigo
        case .delivered: return .green
        case .cancelled: return .red
        case .returned: return .gray
        }
    }
}

// MARK: - Analytics Helpers
struct AnalyticsHelper {
    static func logEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        // Implement analytics logging here (Firebase, Mixpanel, etc.)
        print("Analytics Event: \(eventName), Parameters: \(parameters ?? [:])")
    }
    
    static func logProductView(_ product: Product) {
        logEvent("product_view", parameters: [
            "product_id": product.id,
            "product_title": product.title,
            "product_category": product.category.rawValue,
            "is_donation": product.isDonation
        ])
    }
    
    static func logUserAction(_ action: String, productId: String? = nil) {
        var parameters: [String: Any] = ["action": action]
        if let productId = productId {
            parameters["product_id"] = productId
        }
        logEvent("user_action", parameters: parameters)
    }
}

// MARK: - Storage Helpers
struct StorageHelper {
    static func saveToUserDefaults<T: Codable>(_ object: T, key: String) {
        if let data = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func loadFromUserDefaults<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    static func removeFromUserDefaults(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Device Helpers
struct DeviceHelper {
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    static var isSmallScreen: Bool {
        screenSize.height < 812 // iPhone SE, iPhone 8, etc.
    }
    
    static var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
}