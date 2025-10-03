//
//  CustomButton.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var size: ButtonSize = .large
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var fullWidth: Bool = true
    
    var body: some View {
        Button(action: {
            if !isDisabled && !isLoading {
                HapticFeedback.light.trigger()
                action()
            }
        }) {
            HStack(spacing: AppDimensions.spacingS) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                if !title.isEmpty {
                    Text(title)
                        .font(size.font)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(isDisabled ? style.disabledForegroundColor : style.foregroundColor)
            .frame(height: size.height)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(isDisabled ? style.disabledBackgroundColor : style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .stroke(style.borderColor, lineWidth: style.borderWidth)
                    )
            )
        }
        .disabled(isDisabled || isLoading)
        .scaleEffect(isDisabled ? 0.95 : 1.0)
        .animation(AppAnimations.easeInOut, value: isDisabled)
        .animation(AppAnimations.easeInOut, value: isLoading)
    }
}

// MARK: - Button Styles
extension CustomButton {
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case ghost
        case destructive
        case success
        case warning
        
        var backgroundColor: Color {
            switch self {
            case .primary: return AppColors.primary
            case .secondary: return AppColors.secondary
            case .outline: return Color.clear
            case .ghost: return Color.clear
            case .destructive: return AppColors.error
            case .success: return AppColors.success
            case .warning: return AppColors.warning
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive, .success: return .white
            case .secondary: return AppColors.textPrimary
            case .outline: return AppColors.primary
            case .ghost: return AppColors.textPrimary
            case .warning: return AppColors.textPrimary
            }
        }
        
        var disabledBackgroundColor: Color {
            Color.gray.opacity(0.3)
        }
        
        var disabledForegroundColor: Color {
            Color.gray
        }
        
        var borderColor: Color {
            switch self {
            case .outline: return AppColors.primary
            case .ghost: return Color.clear
            default: return Color.clear
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .outline: return 2
            default: return 0
            }
        }
    }
}

// MARK: - Button Sizes
extension CustomButton {
    enum ButtonSize {
        case small
        case medium
        case large
        case extraLarge
        
        var height: CGFloat {
            switch self {
            case .small: return AppDimensions.buttonHeightS
            case .medium: return AppDimensions.buttonHeight
            case .large: return AppDimensions.buttonHeight
            case .extraLarge: return AppDimensions.buttonHeightL
            }
        }
        
        var font: Font {
            switch self {
            case .small: return AppFonts.labelMedium
            case .medium: return AppFonts.titleMedium
            case .large: return AppFonts.titleLarge
            case .extraLarge: return AppFonts.headlineSmall
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return AppDimensions.cornerRadiusS
            case .medium: return AppDimensions.cornerRadiusM
            case .large: return AppDimensions.cornerRadiusM
            case .extraLarge: return AppDimensions.cornerRadiusL
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return AppDimensions.iconSizeS
            case .medium: return AppDimensions.iconSizeM
            case .large: return AppDimensions.iconSizeM
            case .extraLarge: return AppDimensions.iconSizeL
            }
        }
    }
}

// MARK: - Specialized Buttons

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var icon: String? = nil
    
    var body: some View {
        CustomButton(
            title: title,
            action: action,
            style: .primary,
            size: .large,
            icon: icon,
            isLoading: isLoading,
            isDisabled: isDisabled
        )
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var icon: String? = nil
    
    var body: some View {
        CustomButton(
            title: title,
            action: action,
            style: .secondary,
            size: .large,
            icon: icon,
            isDisabled: isDisabled
        )
    }
}

struct OutlineButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var icon: String? = nil
    
    var body: some View {
        CustomButton(
            title: title,
            action: action,
            style: .outline,
            size: .large,
            icon: icon,
            isDisabled: isDisabled
        )
    }
}

struct DestructiveButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var icon: String? = nil
    
    var body: some View {
        CustomButton(
            title: title,
            action: action,
            style: .destructive,
            size: .large,
            icon: icon,
            isDisabled: isDisabled
        )
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    var icon: String = "plus"
    var backgroundColor: Color = AppColors.primary
    var foregroundColor: Color = .white
    
    var body: some View {
        Button(action: {
            HapticFeedback.medium.trigger()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(foregroundColor)
                .frame(width: 56, height: 56)
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = AppDimensions.iconSizeL
    var backgroundColor: Color = Color.clear
    var foregroundColor: Color = AppColors.textPrimary
    var showBackground: Bool = false
    
    var body: some View {
        Button(action: {
            HapticFeedback.light.trigger()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.6, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(
                    showBackground ? 
                    Circle().fill(backgroundColor) : 
                    Circle().fill(Color.clear)
                )
        }
    }
}

struct SocialLoginButton: View {
    let provider: SocialProvider
    let action: () -> Void
    
    var body: some View {
        CustomButton(
            title: "Continuar con \(provider.name)",
            action: action,
            style: .outline,
            size: .large,
            icon: provider.icon
        )
    }
}

enum SocialProvider {
    case google
    case apple
    case facebook
    
    var name: String {
        switch self {
        case .google: return "Google"
        case .apple: return "Apple"
        case .facebook: return "Facebook"
        }
    }
    
    var icon: String {
        switch self {
        case .google: return "globe"
        case .apple: return "applelogo"
        case .facebook: return "f.circle"
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: AppDimensions.spacingL) {
        PrimaryButton(title: "Botón Principal", action: {})
        
        SecondaryButton(title: "Botón Secundario", action: {}, icon: "heart")
        
        OutlineButton(title: "Botón Outline", action: {})
        
        DestructiveButton(title: "Botón Destructivo", action: {}, icon: "trash")
        
        CustomButton(
            title: "Cargando...",
            action: {},
            style: .primary,
            isLoading: true
        )
        
        CustomButton(
            title: "Deshabilitado",
            action: {},
            style: .primary,
            isDisabled: true
        )
        
        HStack {
            FloatingActionButton(action: {})
            IconButton(icon: "heart", action: {}, showBackground: true)
            IconButton(icon: "share", action: {})
        }
        
        Spacer()
    }
    .padding()
}