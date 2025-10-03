//
//  Extensions.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let primaryGreen = Color(hex: "4CAF50")
    static let secondaryGreen = Color(hex: "81C784")
    static let accentOrange = Color(hex: "FF9800")
    static let backgroundGray = Color(hex: "F5F5F5")
    static let cardWhite = Color(hex: "FFFFFF")
    static let textDark = Color(hex: "333333")
    static let textLight = Color(hex: "757575")
    static let dividerGray = Color(hex: "E0E0E0")
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func cardStyle() -> some View {
        self
            .background(Color.cardWhite)
            .cornerRadius(AppDimensions.cornerRadiusM)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func buttonStyle(backgroundColor: Color = AppColors.primary, foregroundColor: Color = .white) -> some View {
        self
            .frame(height: AppDimensions.buttonHeight)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(AppDimensions.cornerRadiusM)
    }
    
    func textFieldStyle() -> some View {
        self
            .padding(AppDimensions.spacingM)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(AppDimensions.cornerRadiusM)
    }
    
    func profileImageStyle(size: CGFloat = AppDimensions.profileImageM) -> some View {
        self
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
    
    func shimmerEffect() -> some View {
        self.modifier(ShimmerModifier())
    }
    
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnFirstAppearModifier(action: action))
    }
    
    func hapticFeedback(_ type: HapticFeedback) -> some View {
        self.onTapGesture {
            type.trigger()
        }
    }
    
    func hideKeyboard() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[+]?[0-9\\s\\-\\(\\)]{10,}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    func truncated(to length: Int) -> String {
        if self.count > length {
            return String(self.prefix(length)) + "..."
        }
        return self
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - Date Extensions
extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    var formattedMedium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    var formattedLong: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }
    
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
}

// MARK: - Double Extensions
extension Double {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: NSNumber(value: self)) ?? "€0.00"
    }
    
    var formattedDecimal: String {
        return String(format: "%.1f", self)
    }
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Array Extensions
extension Array where Element: Identifiable {
    func removeDuplicates() -> [Element] {
        var seen = Set<Element.ID>()
        return self.filter { seen.insert($0.id).inserted }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - UIApplication Extensions
extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Custom Modifiers
struct ShimmerModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: isAnimating ? 300 : -300)
                    .animation(
                        Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            )
            .clipped()
            .onAppear {
                isAnimating = true
            }
    }
}

struct OnFirstAppearModifier: ViewModifier {
    @State private var hasAppeared = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !hasAppeared {
                    hasAppeared = true
                    action()
                }
            }
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension PreviewDevice {
    static let iPhone14 = PreviewDevice(rawValue: "iPhone 14")
    static let iPhone14Pro = PreviewDevice(rawValue: "iPhone 14 Pro")
    static let iPhone14ProMax = PreviewDevice(rawValue: "iPhone 14 Pro Max")
    static let iPhoneSE = PreviewDevice(rawValue: "iPhone SE (3rd generation)")
}
#endif