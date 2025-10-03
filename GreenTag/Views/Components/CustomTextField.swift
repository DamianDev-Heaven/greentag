//
//  CustomTextField.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var icon: String? = nil
    var errorMessage: String? = nil
    var isRequired: Bool = false
    var maxLength: Int? = nil
    var onEditingChanged: ((Bool) -> Void)? = nil
    var onCommit: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
            // Title
            if !title.isEmpty {
                HStack {
                    Text(title)
                        .font(AppFonts.labelMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if isRequired {
                        Text("*")
                            .font(AppFonts.labelMedium)
                            .foregroundColor(AppColors.error)
                    }
                    
                    Spacer()
                }
            }
            
            // Text Field Container
            HStack(spacing: AppDimensions.spacingM) {
                // Leading Icon
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isFocused ? AppColors.primary : AppColors.textSecondary)
                        .frame(width: AppDimensions.iconSizeM)
                }
                
                // Text Field
                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                    }
                }
                .focused($isFocused)
                .onChange(of: text) { newValue in
                    if let maxLength = maxLength, newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }
                .onEditingChanged { editing in
                    onEditingChanged?(editing)
                }
                .onSubmit {
                    onCommit?()
                }
                
                // Trailing Button (Password visibility toggle)
                if isSecure {
                    Button(action: {
                        isPasswordVisible.toggle()
                        HapticFeedback.light.trigger()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: AppDimensions.iconSizeM)
                    }
                }
            }
            .padding(AppDimensions.spacingM)
            .background(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadiusM)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppDimensions.cornerRadiusM)
                            .stroke(
                                errorMessage != nil ? AppColors.error :
                                isFocused ? AppColors.primary : Color.clear,
                                lineWidth: isFocused || errorMessage != nil ? 2 : 0
                            )
                    )
            )
            
            // Error Message
            if let errorMessage = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(AppColors.error)
                        .font(.caption)
                    
                    Text(errorMessage)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.error)
                    
                    Spacer()
                }
            }
            
            // Character Count (if maxLength is set)
            if let maxLength = maxLength {
                HStack {
                    Spacer()
                    Text("\(text.count)/\(maxLength)")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(
                            text.count > maxLength * 9 / 10 ? AppColors.warning : AppColors.textSecondary
                        )
                }
            }
        }
        .animation(AppAnimations.easeInOut, value: isFocused)
        .animation(AppAnimations.easeInOut, value: errorMessage)
    }
}

// MARK: - Specialized Text Fields

struct EmailTextField: View {
    @Binding var email: String
    var errorMessage: String? = nil
    
    var body: some View {
        CustomTextField(
            title: "Email",
            placeholder: "tu@email.com",
            text: $email,
            keyboardType: .emailAddress,
            icon: "envelope",
            errorMessage: errorMessage,
            isRequired: true
        )
    }
}

struct PasswordTextField: View {
    @Binding var password: String
    var title: String = "Contraseña"
    var errorMessage: String? = nil
    
    var body: some View {
        CustomTextField(
            title: title,
            placeholder: "Introduce tu contraseña",
            text: $password,
            isSecure: true,
            icon: "lock",
            errorMessage: errorMessage,
            isRequired: true
        )
    }
}

struct PhoneTextField: View {
    @Binding var phoneNumber: String
    var errorMessage: String? = nil
    
    var body: some View {
        CustomTextField(
            title: "Teléfono",
            placeholder: "+34 123 456 789",
            text: $phoneNumber,
            keyboardType: .phonePad,
            icon: "phone",
            errorMessage: errorMessage,
            isRequired: true
        )
    }
}

struct SearchTextField: View {
    @Binding var searchText: String
    var placeholder: String = "Buscar productos..."
    var onSearchCommit: (() -> Void)? = nil
    
    var body: some View {
        CustomTextField(
            title: "",
            placeholder: placeholder,
            text: $searchText,
            icon: "magnifyingglass",
            onCommit: onSearchCommit
        )
    }
}

struct PriceTextField: View {
    @Binding var price: String
    var errorMessage: String? = nil
    
    var body: some View {
        CustomTextField(
            title: "Precio",
            placeholder: "0.00",
            text: $price,
            keyboardType: .decimalPad,
            icon: "eurosign.circle",
            errorMessage: errorMessage
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: AppDimensions.spacingL) {
        CustomTextField(
            title: "Nombre",
            placeholder: "Introduce tu nombre",
            text: .constant(""),
            icon: "person",
            isRequired: true
        )
        
        CustomTextField(
            title: "Contraseña",
            placeholder: "Introduce tu contraseña",
            text: .constant(""),
            isSecure: true,
            icon: "lock",
            errorMessage: "La contraseña debe tener al menos 6 caracteres",
            isRequired: true
        )
        
        CustomTextField(
            title: "Descripción",
            placeholder: "Describe tu producto...",
            text: .constant(""),
            maxLength: 500
        )
        
        Spacer()
    }
    .padding()
}