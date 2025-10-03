//
//  AddProductView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct AddProductView: View {
    @StateObject private var productViewModel = ProductViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDimensions.spacingL) {
                    // Header Info
                    headerSection
                    
                    // Images Section
                    imagesSection
                    
                    // Basic Information
                    basicInfoSection
                    
                    // Category and Condition
                    categorySection
                    
                    // Price Section
                    priceSection
                    
                    // Location Section
                    locationSection
                    
                    // Tags Section
                    tagsSection
                    
                    // Submit Button
                    submitSection
                }
                .padding(AppDimensions.spacingL)
            }
            .navigationTitle("Publicar producto")
            .navigationBarTitleDisplayMode(.large)
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
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary)
            
            VStack(spacing: AppDimensions.spacingS) {
                Text("Publica tu producto")
                    .font(AppFonts.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Ayuda al medio ambiente compartiendo productos que ya no uses")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Fotos del producto")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            ImagePickerView(
                selectedImages: $productViewModel.selectedImages,
                maxImages: 5,
                title: "Agregar fotos"
            )
            
            Text("Agrega hasta 5 fotos para mostrar mejor tu producto")
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
        }
        .cardStyle()
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Información básica")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            CustomTextField(
                title: "Título",
                placeholder: "Ej: iPhone 12 Pro en excelente estado",
                text: $productViewModel.title,
                isRequired: true,
                maxLength: 80
            )
            
            CustomTextField(
                title: "Descripción",
                placeholder: "Describe tu producto, su estado, características especiales...",
                text: $productViewModel.description,
                isRequired: true,
                maxLength: 500
            )
        }
        .cardStyle()
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Categoría y estado")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            // Category Picker
            VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                Text("Categoría *")
                    .font(AppFonts.labelMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                Menu {
                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        Button(action: {
                            productViewModel.selectedCategory = category
                            HapticFeedback.light.trigger()
                        }) {
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.displayName)
                                
                                if productViewModel.selectedCategory == category {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: productViewModel.selectedCategory.icon)
                        Text(productViewModel.selectedCategory.displayName)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding(AppDimensions.spacingM)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(AppDimensions.cornerRadiusM)
                    .foregroundColor(AppColors.textPrimary)
                }
            }
            
            // Condition Picker
            VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                Text("Estado *")
                    .font(AppFonts.labelMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                Menu {
                    ForEach(ProductCondition.allCases, id: \.self) { condition in
                        Button(action: {
                            productViewModel.condition = condition
                            HapticFeedback.light.trigger()
                        }) {
                            HStack {
                                Text(condition.displayName)
                                
                                if productViewModel.condition == condition {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(productViewModel.condition.displayName)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding(AppDimensions.spacingM)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(AppDimensions.cornerRadiusM)
                    .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .cardStyle()
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Precio")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            // Donation Toggle
            Toggle(isOn: $productViewModel.isDonation) {
                VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                    Text("Donación gratuita")
                        .font(AppFonts.titleMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Marca esta opción si quieres donar el producto")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: AppColors.success))
            
            // Price Input
            if !productViewModel.isDonation {
                PriceTextField(
                    price: $productViewModel.price,
                    errorMessage: productViewModel.errorMessage?.contains("precio") == true ? productViewModel.errorMessage : nil
                )
            }
        }
        .cardStyle()
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Ubicación")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            CustomTextField(
                title: "Dirección",
                placeholder: "Calle, número, código postal",
                text: $productViewModel.address,
                icon: "location",
                isRequired: true
            )
            
            HStack(spacing: AppDimensions.spacingM) {
                CustomTextField(
                    title: "Ciudad",
                    placeholder: "Madrid",
                    text: $productViewModel.city,
                    icon: "building.2",
                    isRequired: true
                )
                
                CustomTextField(
                    title: "País",
                    placeholder: "España",
                    text: $productViewModel.country,
                    icon: "globe",
                    isRequired: true
                )
            }
        }
        .cardStyle()
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Etiquetas (opcional)")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            // Add Tag Input
            HStack {
                CustomTextField(
                    title: "",
                    placeholder: "Agregar etiqueta...",
                    text: $productViewModel.newTag,
                    icon: "tag"
                )
                
                Button("Agregar") {
                    productViewModel.addTag()
                    HapticFeedback.light.trigger()
                }
                .disabled(productViewModel.newTag.isEmpty)
                .padding(.horizontal, AppDimensions.spacingM)
                .padding(.vertical, AppDimensions.spacingS)
                .background(
                    productViewModel.newTag.isEmpty ? 
                    Color.gray.opacity(0.3) : AppColors.primary
                )
                .foregroundColor(.white)
                .cornerRadius(AppDimensions.cornerRadiusS)
            }
            
            // Tags Display
            if !productViewModel.tags.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80))
                ], alignment: .leading, spacing: AppDimensions.spacingS) {
                    ForEach(productViewModel.tags, id: \.self) { tag in
                        TagView(tag: tag) {
                            productViewModel.removeTag(tag)
                            HapticFeedback.light.trigger()
                        }
                    }
                }
            }
            
            Text("Las etiquetas ayudan a otros usuarios a encontrar tu producto")
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
        }
        .cardStyle()
    }
    
    private var submitSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            PrimaryButton(
                title: "Publicar producto",
                action: {
                    Task {
                        guard let user = authViewModel.currentUser else { return }
                        
                        let success = await productViewModel.createProduct(
                            sellerId: user.id,
                            sellerName: user.fullName,
                            sellerRating: user.averageRating
                        )
                        
                        if success {
                            dismiss()
                            HapticFeedback.success.trigger()
                        }
                    }
                },
                isLoading: productViewModel.isLoading,
                icon: "plus.circle"
            )
            
            // Error Message
            if let errorMessage = productViewModel.errorMessage {
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
}

// MARK: - Tag View
struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: AppDimensions.spacingXS) {
            Text(tag)
                .font(AppFonts.bodySmall)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
            }
        }
        .padding(.horizontal, AppDimensions.spacingS)
        .padding(.vertical, 6)
        .background(AppColors.primary.opacity(0.1))
        .foregroundColor(AppColors.primary)
        .cornerRadius(AppDimensions.cornerRadiusS)
    }
}

// MARK: - Preview
#Preview {
    AddProductView()
        .environmentObject(AuthViewModel())
}