//
//  SettingsView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("pushNotificationsEnabled") private var pushNotificationsEnabled = true
    @AppStorage("emailNotificationsEnabled") private var emailNotificationsEnabled = true
    @AppStorage("marketingNotificationsEnabled") private var marketingNotificationsEnabled = false
    @AppStorage("dataAnalyticsEnabled") private var dataAnalyticsEnabled = true
    @AppStorage("crashReportingEnabled") private var crashReportingEnabled = true
    @AppStorage("locationServicesEnabled") private var locationServicesEnabled = true
    @AppStorage("biometricAuthEnabled") private var biometricAuthEnabled = false
    
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingAboutSheet = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            List {
                // User Section
                userSection
                
                // Appearance
                Section("Apariencia") {
                    appearanceSettings
                }
                
                // Notifications
                Section("Notificaciones") {
                    notificationSettings
                }
                
                // Privacy & Security
                Section("Privacidad y Seguridad") {
                    privacyAndSecuritySettings
                }
                
                // Data & Storage
                Section("Datos y Almacenamiento") {
                    dataStorageSettings
                }
                
                // Support & About
                Section("Soporte y Acerca de") {
                    supportAndAboutSettings
                }
                
                // Account Actions
                Section("Cuenta") {
                    accountActions
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .alert("Cerrar Sesión", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar Sesión", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
            .alert("Eliminar Cuenta", isPresented: $showingDeleteAccountAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Esta acción no se puede deshacer. Se eliminarán todos tus datos permanentemente.")
            }
            .sheet(isPresented: $showingAboutSheet) {
                AboutView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                WebView(url: "https://greentag.com/privacy", title: "Política de Privacidad")
            }
            .sheet(isPresented: $showingTermsOfService) {
                WebView(url: "https://greentag.com/terms", title: "Términos de Servicio")
            }
        }
    }
    
    private var userSection: some View {
        Section {
            HStack(spacing: AppDimensions.spacingM) {
                // Profile Image
                AsyncImage(url: URL(string: authViewModel.currentUser?.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(AppColors.primary.opacity(0.2))
                        .overlay(
                            Text(String(authViewModel.currentUser?.name.prefix(1) ?? "?"))
                                .font(AppFonts.titleLarge)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primary)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.currentUser?.name ?? "Usuario")
                        .font(AppFonts.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(authViewModel.currentUser?.email ?? "")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    
                    // Level Badge
                    if let level = authViewModel.currentUser?.level {
                        HStack(spacing: 4) {
                            Image(systemName: level.icon)
                                .font(.system(size: 12))
                                .foregroundColor(Color(level.color))
                            
                            Text(level.displayName)
                                .font(AppFonts.labelSmall)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, AppDimensions.spacingS)
        }
    }
    
    private var appearanceSettings: some View {
        Group {
            HStack {
                Image(systemName: "moon.fill")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                Text("Modo oscuro")
                    .font(AppFonts.bodyMedium)
                
                Spacer()
                
                Toggle("", isOn: $isDarkMode)
                    .labelsHidden()
                    .tint(AppColors.primary)
            }
        }
    }
    
    private var notificationSettings: some View {
        Group {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                Text("Notificaciones push")
                    .font(AppFonts.bodyMedium)
                
                Spacer()
                
                Toggle("", isOn: $pushNotificationsEnabled)
                    .labelsHidden()
                    .tint(AppColors.primary)
                    .onChange(of: pushNotificationsEnabled) { enabled in
                        updatePushNotificationPermissions(enabled)
                    }
            }
            
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                Text("Notificaciones por email")
                    .font(AppFonts.bodyMedium)
                
                Spacer()
                
                Toggle("", isOn: $emailNotificationsEnabled)
                    .labelsHidden()
                    .tint(AppColors.primary)
            }
            
            HStack {
                Image(systemName: "megaphone.fill")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Promociones y ofertas")
                        .font(AppFonts.bodyMedium)
                    
                    Text("Recibe notificaciones sobre ofertas especiales")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $marketingNotificationsEnabled)
                    .labelsHidden()
                    .tint(AppColors.primary)
            }
        }
    }
    
    private var privacyAndSecuritySettings: some View {
        Group {
            HStack {
                Image(systemName: "faceid")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Autenticación biométrica")
                        .font(AppFonts.bodyMedium)
                    
                    Text("Usa Face ID o Touch ID para acceder")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $biometricAuthEnabled)
                    .labelsHidden()
                    .tint(AppColors.primary)
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Servicios de ubicación")
                        .font(AppFonts.bodyMedium)
                    
                    Text("Permite mostrar productos cercanos")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $locationServicesEnabled)
                    .labelsHidden()
                    .tint(AppColors.primary)
            }
            
            NavigationLink(destination: Text("Configuración de Privacidad")) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24)
                    
                    Text("Configuración de privacidad")
                        .font(AppFonts.bodyMedium)
                }
            }
        }
    }
    
    private var dataStorageSettings: some View {
        Group {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Análisis de datos")
                        .font(AppFonts.bodyMedium)
                    
                    Text("Ayuda a mejorar la aplicación")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $dataAnalyticsEnabled)
                    .labelsHidden()
                    .tint(AppColors.primary)
            }
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reportes de errores")
                        .font(AppFonts.bodyMedium)
                    
                    Text("Envía reportes automáticos de errores")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $crashReportingEnabled)
                    .labelsHidden()
                    .tint(AppColors.primary)
            }
            
            Button(action: clearCache) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Limpiar caché")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Libera espacio eliminando archivos temporales")
                            .font(AppFonts.labelSmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private var supportAndAboutSettings: some View {
        Group {
            Button(action: contactSupport) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24)
                    
                    Text("Contactar soporte")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Button(action: { showingAboutSheet = true }) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24)
                    
                    Text("Acerca de GreenTag")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Button(action: { showingPrivacyPolicy = true }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24)
                    
                    Text("Política de privacidad")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Button(action: { showingTermsOfService = true }) {
                HStack {
                    Image(systemName: "doc.plaintext.fill")
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24)
                    
                    Text("Términos de servicio")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 24)
                
                Text("Versión 1.0.0 (123)")
                    .font(AppFonts.labelSmall)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
        }
    }
    
    private var accountActions: some View {
        Group {
            Button(action: { showingLogoutAlert = true }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(AppColors.warning)
                        .frame(width: 24)
                    
                    Text("Cerrar sesión")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.warning)
                    
                    Spacer()
                }
            }
            
            Button(action: { showingDeleteAccountAlert = true }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(AppColors.error)
                        .frame(width: 24)
                    
                    Text("Eliminar cuenta")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.error)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func updatePushNotificationPermissions(_ enabled: Bool) {
        if enabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if !granted {
                        pushNotificationsEnabled = false
                    }
                }
            }
        }
    }
    
    private func clearCache() {
        // TODO: Implement cache clearing
        HapticFeedback.success.trigger()
    }
    
    private func contactSupport() {
        guard let url = URL(string: "mailto:support@greentag.com?subject=GreenTag%20Support") else { return }
        UIApplication.shared.open(url)
    }
    
    private func deleteAccount() {
        isLoading = true
        
        Task {
            do {
                // TODO: Implement account deletion
                await MainActor.run {
                    authViewModel.signOut()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    // Handle error
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDimensions.spacingL) {
                    // App Icon
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.primary)
                    
                    VStack(spacing: AppDimensions.spacingM) {
                        Text("GreenTag")
                            .font(AppFonts.headlineLarge)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Versión 1.0.0")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("El marketplace ecológico que conecta a personas comprometidas con el medio ambiente")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppDimensions.spacingL)
                    }
                    
                    VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
                        Text("Características principales:")
                            .font(AppFonts.titleMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                            FeatureRow(icon: "cart.fill", text: "Marketplace de productos ecológicos")
                            FeatureRow(icon: "star.fill", text: "Sistema de rankings y niveles")
                            FeatureRow(icon: "message.fill", text: "Comunicación directa entre usuarios")
                            FeatureRow(icon: "location.fill", text: "Búsqueda por ubicación")
                            FeatureRow(icon: "leaf.fill", text: "Certificaciones ecológicas")
                        }
                    }
                    .padding(.horizontal, AppDimensions.spacingL)
                    
                    VStack(spacing: AppDimensions.spacingM) {
                        Text("© 2024 GreenTag. Todos los derechos reservados.")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Hecho con ❤️ para el planeta")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(.top, AppDimensions.spacingL)
                }
                .padding(AppDimensions.spacingL)
            }
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppDimensions.spacingM) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primary)
                .frame(width: 20)
            
            Text(text)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

struct WebView: View {
    let url: String
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            // TODO: Implement WebView for showing web content
            Text("Web content would be loaded here")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}