//
//  EditProfileView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var imageService = ImageService()
    
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var location: String = ""
    @State private var phone: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var showingPhotoPicker = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Environmental preferences
    @State private var favoriteCategories: Set<ProductCategory> = []
    @State private var sustainabilityGoals: Set<SustainabilityGoal> = []
    @State private var privacySettings = PrivacySettings()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDimensions.spacingL) {
                    // Profile Photo Section
                    profilePhotoSection
                    
                    // Basic Information
                    basicInformationSection
                    
                    // Contact Information
                    contactInformationSection
                    
                    // Environmental Preferences
                    environmentalPreferencesSection
                    
                    // Privacy Settings
                    privacySettingsSection
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding(AppDimensions.spacingL)
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
                    .disabled(isLoading)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .alert("Información", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            loadCurrentUserData()
        }
        .onChange(of: selectedPhoto) { newPhoto in
            Task {
                await loadSelectedPhoto(newPhoto)
            }
        }
    }
    
    private var profilePhotoSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            Text("Foto de perfil")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Spacer()
                
                Button(action: {
                    showingPhotoPicker = true
                }) {
                    ZStack {
                        if let profileImage {
                            profileImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else if let currentUser = authViewModel.currentUser,
                                  let imageURL = currentUser.profileImageURL {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } placeholder: {
                                defaultProfileImage
                            }
                        } else {
                            defaultProfileImage
                        }
                        
                        // Camera overlay
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .photosPicker(isPresented: $showingPhotoPicker, 
                             selection: $selectedPhoto,
                             matching: .images)
                
                Spacer()
            }
        }
        .cardStyle()
    }
    
    private var defaultProfileImage: some View {
        Circle()
            .fill(AppColors.primary.opacity(0.2))
            .frame(width: 120, height: 120)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primary)
            )
    }
    
    private var basicInformationSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Información básica")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppDimensions.spacingM) {
                CustomTextField(
                    placeholder: "Nombre completo",
                    text: $name,
                    icon: "person"
                )
                
                VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                    Text("Biografía")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextEditor(text: $bio)
                        .padding(AppDimensions.spacingM)
                        .background(Color.white)
                        .cornerRadius(AppDimensions.cornerRadiusM)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppDimensions.cornerRadiusM)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 80)
                    
                    Text("\(bio.count)/150")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(bio.count > 150 ? AppColors.error : AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                CustomTextField(
                    placeholder: "Ubicación",
                    text: $location,
                    icon: "location"
                )
            }
        }
        .cardStyle()
    }
    
    private var contactInformationSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Información de contacto")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            CustomTextField(
                placeholder: "Teléfono (opcional)",
                text: $phone,
                icon: "phone"
            )
            .keyboardType(.phonePad)
            
            Text("Tu información de contacto solo será visible para compradores confirmados")
                .font(AppFonts.labelSmall)
                .foregroundColor(AppColors.textSecondary)
        }
        .cardStyle()
    }
    
    private var environmentalPreferencesSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Preferencias ecológicas")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
                // Favorite Categories
                VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                    Text("Categorías de interés")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textSecondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppDimensions.spacingS) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            categoryButton(category)
                        }
                    }
                }
                
                // Sustainability Goals
                VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                    Text("Objetivos de sostenibilidad")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textSecondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: AppDimensions.spacingS) {
                        ForEach(SustainabilityGoal.allCases, id: \.self) { goal in
                            goalButton(goal)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private func categoryButton(_ category: ProductCategory) -> some View {
        Button(action: {
            if favoriteCategories.contains(category) {
                favoriteCategories.remove(category)
            } else {
                favoriteCategories.insert(category)
            }
            HapticFeedback.light.trigger()
        }) {
            HStack(spacing: AppDimensions.spacingS) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                
                Text(category.displayName)
                    .font(AppFonts.bodySmall)
                
                Spacer()
                
                if favoriteCategories.contains(category) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, AppDimensions.spacingM)
            .padding(.vertical, AppDimensions.spacingS)
            .background(
                favoriteCategories.contains(category) ?
                AppColors.primary : Color.gray.opacity(0.1)
            )
            .foregroundColor(
                favoriteCategories.contains(category) ?
                .white : AppColors.textPrimary
            )
            .cornerRadius(AppDimensions.cornerRadiusM)
        }
    }
    
    private func goalButton(_ goal: SustainabilityGoal) -> some View {
        Button(action: {
            if sustainabilityGoals.contains(goal) {
                sustainabilityGoals.remove(goal)
            } else {
                sustainabilityGoals.insert(goal)
            }
            HapticFeedback.light.trigger()
        }) {
            HStack(spacing: AppDimensions.spacingM) {
                Image(systemName: goal.icon)
                    .font(.system(size: 16))
                    .foregroundColor(
                        sustainabilityGoals.contains(goal) ?
                        .white : AppColors.primary
                    )
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(AppFonts.bodyMedium)
                        .fontWeight(.medium)
                    
                    Text(goal.description)
                        .font(AppFonts.labelSmall)
                        .opacity(0.8)
                }
                
                Spacer()
                
                if sustainabilityGoals.contains(goal) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(AppDimensions.spacingM)
            .background(
                sustainabilityGoals.contains(goal) ?
                AppColors.primary : Color.gray.opacity(0.1)
            )
            .foregroundColor(
                sustainabilityGoals.contains(goal) ?
                .white : AppColors.textPrimary
            )
            .cornerRadius(AppDimensions.cornerRadiusM)
        }
    }
    
    private var privacySettingsSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Configuración de privacidad")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppDimensions.spacingM) {
                privacyToggle(
                    title: "Perfil público",
                    description: "Permite que otros usuarios vean tu perfil",
                    binding: $privacySettings.isProfilePublic
                )
                
                privacyToggle(
                    title: "Mostrar estadísticas",
                    description: "Muestra tus puntos y nivel en tu perfil",
                    binding: $privacySettings.showStats
                )
                
                privacyToggle(
                    title: "Mostrar actividad reciente",
                    description: "Permite ver tus productos y reviews recientes",
                    binding: $privacySettings.showRecentActivity
                )
                
                privacyToggle(
                    title: "Permitir mensajes directos",
                    description: "Otros usuarios pueden enviarte mensajes",
                    binding: $privacySettings.allowDirectMessages
                )
            }
        }
        .cardStyle()
    }
    
    private func privacyToggle(title: String, description: String, binding: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(AppFonts.labelSmall)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(AppColors.primary)
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            CustomButton(
                title: isLoading ? "Guardando..." : "Guardar cambios",
                isLoading: isLoading,
                action: saveChanges
            )
            
            Button("Eliminar cuenta") {
                // TODO: Implement account deletion
            }
            .font(AppFonts.bodyMedium)
            .foregroundColor(AppColors.error)
        }
    }
    
    // MARK: - Functions
    
    private func loadCurrentUserData() {
        guard let currentUser = authViewModel.currentUser else { return }
        
        name = currentUser.name
        bio = currentUser.bio ?? ""
        location = currentUser.location ?? ""
        phone = currentUser.phone ?? ""
        favoriteCategories = Set(currentUser.favoriteCategories ?? [])
        sustainabilityGoals = Set(currentUser.sustainabilityGoals ?? [])
        // Load privacy settings from user data
    }
    
    private func loadSelectedPhoto(_ photo: PhotosPickerItem?) async {
        guard let photo = photo else { return }
        
        do {
            if let data = try await photo.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
        } catch {
            await MainActor.run {
                alertMessage = "Error al cargar la imagen: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func saveChanges() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "El nombre es obligatorio"
            showingAlert = true
            return
        }
        
        guard bio.count <= 150 else {
            alertMessage = "La biografía no puede superar los 150 caracteres"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // TODO: Update user profile through service
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Perfil actualizado correctamente"
                    showingAlert = true
                    
                    // Update current user in auth view model
                    if var currentUser = authViewModel.currentUser {
                        currentUser.name = name
                        currentUser.bio = bio.isEmpty ? nil : bio
                        currentUser.location = location.isEmpty ? nil : location
                        currentUser.phone = phone.isEmpty ? nil : phone
                        currentUser.favoriteCategories = Array(favoriteCategories)
                        currentUser.sustainabilityGoals = Array(sustainabilityGoals)
                        authViewModel.currentUser = currentUser
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Error al actualizar el perfil: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Supporting Types

enum SustainabilityGoal: CaseIterable, Hashable {
    case reduceWaste
    case buyLocal
    case useRenewableEnergy
    case supportEthicalBrands
    case minimizeCarbon
    case conserveWater
    
    var title: String {
        switch self {
        case .reduceWaste: return "Reducir residuos"
        case .buyLocal: return "Comprar local"
        case .useRenewableEnergy: return "Energía renovable"
        case .supportEthicalBrands: return "Marcas éticas"
        case .minimizeCarbon: return "Minimizar huella de carbono"
        case .conserveWater: return "Conservar agua"
        }
    }
    
    var description: String {
        switch self {
        case .reduceWaste: return "Minimizar la generación de residuos"
        case .buyLocal: return "Apoyar productores locales"
        case .useRenewableEnergy: return "Usar fuentes de energía limpia"
        case .supportEthicalBrands: return "Elegir marcas responsables"
        case .minimizeCarbon: return "Reducir emisiones de CO2"
        case .conserveWater: return "Uso eficiente del agua"
        }
    }
    
    var icon: String {
        switch self {
        case .reduceWaste: return "trash.slash"
        case .buyLocal: return "location.circle"
        case .useRenewableEnergy: return "bolt.fill"
        case .supportEthicalBrands: return "hand.raised.fill"
        case .minimizeCarbon: return "leaf.fill"
        case .conserveWater: return "drop.fill"
        }
    }
}

struct PrivacySettings {
    var isProfilePublic: Bool = true
    var showStats: Bool = true
    var showRecentActivity: Bool = true
    var allowDirectMessages: Bool = true
}

// MARK: - Preview
#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}