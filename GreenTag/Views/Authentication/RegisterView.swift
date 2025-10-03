//
//  RegisterView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDimensions.spacingL) {
                    // Header
                    headerSection
                    
                    // Registration Form
                    registrationForm
                    
                    // Terms and Privacy
                    termsSection
                    
                    // Register Button
                    registerButton
                    
                    // Login Link
                    loginSection
                }
                .padding(AppDimensions.spacingL)
            }
            .navigationTitle("Crear cuenta")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                        HapticFeedback.light.trigger()
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .hideKeyboard()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary)
            
            VStack(spacing: AppDimensions.spacingS) {
                Text("Únete a GreenTag")
                    .font(AppFonts.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Crea tu cuenta y comienza a contribuir al cuidado del medio ambiente")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var registrationForm: some View {
        VStack(spacing: AppDimensions.spacingL) {
            // Personal Information
            VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
                Text("Información personal")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: AppDimensions.spacingM) {
                    CustomTextField(
                        title: "Nombre",
                        placeholder: "Juan",
                        text: $authViewModel.firstName,
                        icon: "person",
                        isRequired: true
                    )
                    
                    CustomTextField(
                        title: "Apellido",
                        placeholder: "García",
                        text: $authViewModel.lastName,
                        icon: "person",
                        isRequired: true
                    )
                }
                
                EmailTextField(
                    email: $authViewModel.email,
                    errorMessage: authViewModel.errorMessage?.contains("email") == true ? authViewModel.errorMessage : nil
                )
                
                PhoneTextField(
                    phoneNumber: $authViewModel.phoneNumber,
                    errorMessage: authViewModel.errorMessage?.contains("teléfono") == true ? authViewModel.errorMessage : nil
                )
            }
            .cardStyle()
            
            // Location Information
            VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
                Text("Ubicación")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                CustomTextField(
                    title: "País",
                    placeholder: "España",
                    text: $authViewModel.country,
                    icon: "globe",
                    isRequired: true
                )
                
                CustomTextField(
                    title: "Ciudad",
                    placeholder: "Madrid",
                    text: $authViewModel.city,
                    icon: "building.2",
                    isRequired: true
                )
            }
            .cardStyle()
            
            // Security Information
            VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
                Text("Seguridad")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                PasswordTextField(
                    password: $authViewModel.password,
                    title: "Contraseña",
                    errorMessage: authViewModel.errorMessage?.contains("contraseña") == true ? authViewModel.errorMessage : nil
                )
                
                PasswordTextField(
                    password: $authViewModel.confirmPassword,
                    title: "Confirmar contraseña",
                    errorMessage: authViewModel.errorMessage?.contains("coinciden") == true ? authViewModel.errorMessage : nil
                )
                
                // Password Requirements
                passwordRequirements
            }
            .cardStyle()
        }
    }
    
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
            Text("La contraseña debe tener:")
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
            
            HStack {
                Image(systemName: authViewModel.password.count >= 6 ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(authViewModel.password.count >= 6 ? AppColors.success : AppColors.textSecondary)
                    .font(.caption)
                
                Text("Al menos 6 caracteres")
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
            
            HStack {
                Image(systemName: authViewModel.password == authViewModel.confirmPassword && !authViewModel.password.isEmpty ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(authViewModel.password == authViewModel.confirmPassword && !authViewModel.password.isEmpty ? AppColors.success : AppColors.textSecondary)
                    .font(.caption)
                
                Text("Las contraseñas coinciden")
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
        }
        .padding(AppDimensions.spacingM)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(AppDimensions.cornerRadiusS)
    }
    
    private var termsSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            Text("Al crear una cuenta, aceptas nuestros")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Button("Términos de Servicio") {
                    // TODO: Show terms of service
                    HapticFeedback.light.trigger()
                }
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.primary)
                
                Text("y")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                
                Button("Política de Privacidad") {
                    // TODO: Show privacy policy
                    HapticFeedback.light.trigger()
                }
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.primary)
            }
        }
    }
    
    private var registerButton: some View {
        VStack(spacing: AppDimensions.spacingM) {
            PrimaryButton(
                title: "Crear cuenta",
                action: {
                    Task {
                        await authViewModel.register()
                        if authViewModel.isAuthenticated {
                            dismiss()
                        }
                    }
                },
                isLoading: authViewModel.isLoading,
                isDisabled: !isFormValid,
                icon: "person.badge.plus"
            )
            
            // Error Message
            if let errorMessage = authViewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppColors.error)
                    
                    Text(errorMessage)
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.error)
                    
                    Spacer()
                }
                .padding(AppDimensions.spacingM)
                .background(AppColors.error.opacity(0.1))
                .cornerRadius(AppDimensions.cornerRadiusM)
            }
        }
    }
    
    private var loginSection: some View {
        HStack {
            Text("¿Ya tienes cuenta?")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
            
            Button("Inicia sesión") {
                dismiss()
                HapticFeedback.light.trigger()
            }
            .font(AppFonts.bodyMedium)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.primary)
        }
        .padding(.bottom, AppDimensions.spacingXL)
    }
    
    private var isFormValid: Bool {
        !authViewModel.firstName.isEmpty &&
        !authViewModel.lastName.isEmpty &&
        !authViewModel.email.isEmpty &&
        !authViewModel.phoneNumber.isEmpty &&
        !authViewModel.country.isEmpty &&
        !authViewModel.city.isEmpty &&
        authViewModel.password.count >= 6 &&
        authViewModel.password == authViewModel.confirmPassword
    }
}

// MARK: - Preview
#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}