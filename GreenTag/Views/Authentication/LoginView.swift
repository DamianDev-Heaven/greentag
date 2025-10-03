//
//  LoginView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDimensions.spacingXL) {
                    // Logo and Header
                    headerSection
                    
                    // Login Form
                    loginForm
                    
                    // Divider
                    dividerSection
                    
                    // Social Login
                    socialLoginSection
                    
                    // Register Link
                    registerSection
                }
                .padding(AppDimensions.spacingL)
            }
            .navigationBarHidden(true)
            .background(AppColors.background.ignoresSafeArea())
            .hideKeyboard()
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppDimensions.spacingL) {
            // Logo
            VStack(spacing: AppDimensions.spacingM) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primary)
                
                VStack(spacing: AppDimensions.spacingS) {
                    Text("GreenTag")
                        .font(AppFonts.displayLarge)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Marketplace ecológico")
                        .font(AppFonts.bodyLarge)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            // Welcome message
            VStack(spacing: AppDimensions.spacingS) {
                Text("¡Bienvenido de vuelta!")
                    .font(AppFonts.headlineMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Inicia sesión para continuar comprando y vendiendo de forma ecológica")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, AppDimensions.spacingXL)
    }
    
    private var loginForm: some View {
        VStack(spacing: AppDimensions.spacingL) {
            // Email Field
            EmailTextField(
                email: $authViewModel.loginEmail,
                errorMessage: authViewModel.errorMessage?.contains("email") == true ? authViewModel.errorMessage : nil
            )
            
            // Password Field
            PasswordTextField(
                password: $authViewModel.loginPassword,
                errorMessage: authViewModel.errorMessage?.contains("contraseña") == true ? authViewModel.errorMessage : nil
            )
            
            // Forgot Password
            HStack {
                Spacer()
                Button("¿Olvidaste tu contraseña?") {
                    // TODO: Implement forgot password
                    HapticFeedback.light.trigger()
                }
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.primary)
            }
            
            // Login Button
            PrimaryButton(
                title: "Iniciar sesión",
                action: {
                    Task {
                        await authViewModel.login()
                    }
                },
                isLoading: authViewModel.isLoading,
                isDisabled: authViewModel.loginEmail.isEmpty || authViewModel.loginPassword.isEmpty
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
        .cardStyle()
        .padding(.horizontal, AppDimensions.spacingM)
    }
    
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1)
            
            Text("o continúa con")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, AppDimensions.spacingM)
            
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1)
        }
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            SocialLoginButton(provider: .apple) {
                // TODO: Implement Apple Sign In
                HapticFeedback.light.trigger()
            }
            
            SocialLoginButton(provider: .google) {
                // TODO: Implement Google Sign In
                HapticFeedback.light.trigger()
            }
        }
    }
    
    private var registerSection: some View {
        HStack {
            Text("¿No tienes cuenta?")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
            
            Button("Regístrate") {
                showingRegister = true
                HapticFeedback.light.trigger()
            }
            .font(AppFonts.bodyMedium)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.primary)
        }
        .padding(.bottom, AppDimensions.spacingXL)
    }
}

// MARK: - Demo Login Helper
struct DemoLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: AppDimensions.spacingM) {
            Text("Demo Login")
                .font(AppFonts.headlineSmall)
                .foregroundColor(AppColors.textSecondary)
            
            Text("Email: demo@greentag.com")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
            
            Text("Contraseña: demo123")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
            
            SecondaryButton(
                title: "Usar credenciales demo",
                action: {
                    authViewModel.loginEmail = "demo@greentag.com"
                    authViewModel.loginPassword = "demo123"
                    HapticFeedback.light.trigger()
                }
            )
        }
        .padding(AppDimensions.spacingL)
        .background(AppColors.secondary.opacity(0.1))
        .cornerRadius(AppDimensions.cornerRadiusM)
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}