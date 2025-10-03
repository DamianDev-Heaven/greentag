//
//  ProductDetailView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @StateObject private var productViewModel = ProductViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex = 0
    @State private var showingContactSeller = false
    @State private var isFavorite = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Image Gallery
                imageGallerySection
                
                // Product Information
                VStack(spacing: AppDimensions.spacingL) {
                    // Basic Info
                    basicInfoSection
                    
                    // Seller Info
                    sellerInfoSection
                    
                    // Description
                    descriptionSection
                    
                    // Location and Shipping
                    locationSection
                    
                    // Tags
                    if !product.tags.isEmpty {
                        tagsSection
                    }
                }
                .padding(AppDimensions.spacingL)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                    HapticFeedback.light.trigger()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    // Share Button
                    Button(action: {
                        // TODO: Implement sharing
                        HapticFeedback.light.trigger()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Favorite Button
                    Button(action: {
                        isFavorite.toggle()
                        HapticFeedback.medium.trigger()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isFavorite ? .red : AppColors.textPrimary)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .sheet(isPresented: $showingContactSeller) {
            ContactSellerView(product: product)
        }
    }
    
    private var imageGallerySection: some View {
        TabView(selection: $selectedImageIndex) {
            ForEach(Array(product.imageURLs.enumerated()), id: \.offset) { index, imageURL in
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.5)
                        )
                }
                .frame(height: 300)
                .clipped()
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 300)
        .overlay(
            // Image Counter
            VStack {
                HStack {
                    Spacer()
                    
                    Text("\(selectedImageIndex + 1)/\(product.imageURLs.count)")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppDimensions.spacingM)
                        .padding(.vertical, AppDimensions.spacingS)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(AppDimensions.cornerRadiusL)
                }
                
                Spacer()
            }
            .padding(AppDimensions.spacingM)
        )
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            // Title and Price
            VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                Text(product.title)
                    .font(AppFonts.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(product.formattedPrice)
                    .font(AppFonts.headlineMedium)
                    .fontWeight(.bold)
                    .foregroundColor(product.isDonation ? AppColors.success : AppColors.primary)
            }
            
            // Badges
            HStack(spacing: AppDimensions.spacingM) {
                CategoryBadge(category: product.category)
                ConditionBadge(condition: product.condition)
                
                if product.isDonation {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                        Text("DONACIÓN")
                            .font(AppFonts.labelSmall)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppDimensions.spacingS)
                    .padding(.vertical, 4)
                    .background(AppColors.success)
                    .cornerRadius(AppDimensions.cornerRadiusS)
                }
                
                Spacer()
            }
            
            // Stats
            HStack(spacing: AppDimensions.spacingL) {
                statItem(icon: "eye", value: "\(product.viewCount)", label: "Visitas")
                statItem(icon: "heart", value: "\(product.favoriteCount)", label: "Favoritos")
                statItem(icon: "clock", value: product.timeAgoString, label: "Publicado")
            }
        }
    }
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: AppDimensions.spacingXS) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(AppFonts.bodySmall)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(label)
                    .font(AppFonts.labelSmall)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    private var sellerInfoSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Vendedor")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: AppDimensions.spacingM) {
                // Seller Avatar
                AsyncImage(url: URL(string: "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(AppColors.primary.opacity(0.2))
                        .overlay(
                            Text(String(product.sellerName.prefix(1)))
                                .font(AppFonts.titleLarge)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primary)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                    Text(product.sellerName)
                        .font(AppFonts.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    RatingView(
                        rating: product.sellerRating,
                        size: .medium
                    )
                    
                    Text("Miembro verificado")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.success)
                }
                
                Spacer()
                
                Button("Ver perfil") {
                    // TODO: Navigate to seller profile
                    HapticFeedback.light.trigger()
                }
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.primary)
            }
        }
        .cardStyle()
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Descripción")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            Text(product.description)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(4)
        }
        .cardStyle()
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Ubicación y entrega")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(AppColors.primary)
                    
                    Text(product.location.fullAddress)
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "shippingbox.fill")
                        .foregroundColor(AppColors.primary)
                    
                    Text("Envío disponible")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text("Desde 3.99€")
                        .font(AppFonts.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(AppColors.primary)
                    
                    Text("Entrega en persona")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text("Gratis")
                        .font(AppFonts.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.success)
                }
            }
        }
        .cardStyle()
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Etiquetas")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80))
            ], alignment: .leading, spacing: AppDimensions.spacingS) {
                ForEach(product.tags, id: \.self) { tag in
                    Text(tag)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, AppDimensions.spacingS)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(AppDimensions.cornerRadiusS)
                }
            }
        }
        .cardStyle()
    }
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: AppDimensions.spacingM) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.formattedPrice)
                        .font(AppFonts.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(product.isDonation ? AppColors.success : AppColors.primary)
                    
                    if !product.isDonation {
                        Text("+ gastos de envío")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                PrimaryButton(
                    title: product.isDonation ? "Lo quiero" : "Contactar",
                    action: {
                        showingContactSeller = true
                        HapticFeedback.medium.trigger()
                    },
                    size: .medium,
                    icon: product.isDonation ? "heart.fill" : "message.fill",
                    fullWidth: false
                )
                .frame(width: 140)
            }
            .padding(AppDimensions.spacingL)
        }
        .background(Color.white)
    }
}

// MARK: - Contact Seller View
struct ContactSellerView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppDimensions.spacingL) {
                // Product Summary
                HStack(spacing: AppDimensions.spacingM) {
                    AsyncImage(url: URL(string: product.primaryImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(AppDimensions.cornerRadiusM)
                    
                    VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                        Text(product.title)
                            .font(AppFonts.titleMedium)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                        
                        Text(product.formattedPrice)
                            .font(AppFonts.bodyMedium)
                            .fontWeight(.bold)
                            .foregroundColor(product.isDonation ? AppColors.success : AppColors.primary)
                        
                        Text("Por \(product.sellerName)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                .cardStyle()
                
                // Message Input
                VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
                    Text("Mensaje")
                        .font(AppFonts.titleLarge)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .padding(AppDimensions.spacingM)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(AppDimensions.cornerRadiusM)
                    
                    Text("Escribe un mensaje para el vendedor")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                .cardStyle()
                
                Spacer()
                
                // Send Button
                PrimaryButton(
                    title: "Enviar mensaje",
                    action: {
                        // TODO: Send message
                        dismiss()
                        HapticFeedback.success.trigger()
                    },
                    isDisabled: message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    icon: "paperplane.fill"
                )
            }
            .padding(AppDimensions.spacingL)
            .navigationTitle("Contactar vendedor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            message = product.isDonation ? 
            "Hola, me interesa tu donación. ¿Cuándo podría recogerla?" :
            "Hola, me interesa tu producto. ¿Podríamos coordinar la entrega?"
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ProductDetailView(product: Product.sampleProducts[0])
    }
}