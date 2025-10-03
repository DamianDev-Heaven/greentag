//
//  ProfileView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDimensions.spacingL) {
                    // Profile Header
                    profileHeaderSection
                    
                    // Stats Section
                    statsSection
                    
                    // Tab Content
                    tabContentSection
                }
                .padding(AppDimensions.spacingL)
            }
            .navigationTitle("Mi Perfil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Configuración") {
                        showingSettings = true
                        HapticFeedback.light.trigger()
                    }
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.primary)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .task {
            if let userId = authViewModel.currentUser?.id {
                await profileViewModel.loadUserProfile(userId: userId)
            }
        }
    }
    
    private var profileHeaderSection: some View {
        VStack(spacing: AppDimensions.spacingL) {
            // Profile Image and Basic Info
            VStack(spacing: AppDimensions.spacingM) {
                // Profile Image
                AsyncImage(url: URL(string: authViewModel.currentUser?.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(AppColors.primary.opacity(0.2))
                        .overlay(
                            Text(String(authViewModel.currentUser?.firstName.prefix(1) ?? "U"))
                                .font(AppFonts.displayMedium)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primary)
                        )
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppColors.primary.opacity(0.3), lineWidth: 4)
                )
                
                // Name and Rating
                VStack(spacing: AppDimensions.spacingS) {
                    Text(authViewModel.currentUser?.fullName ?? "Usuario")
                        .font(AppFonts.headlineLarge)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack(spacing: AppDimensions.spacingM) {
                        RatingView(
                            rating: authViewModel.currentUser?.averageRating ?? 0,
                            size: .large
                        )
                        
                        Text("(\(authViewModel.currentUser?.totalReviews ?? 0) reseñas)")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    // Verification Badge
                    if authViewModel.currentUser?.isVerified == true {
                        HStack(spacing: AppDimensions.spacingXS) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppColors.success)
                            
                            Text("Perfil verificado")
                                .font(AppFonts.bodyMedium)
                                .foregroundColor(AppColors.success)
                        }
                    }
                }
            }
            
            // Edit Profile Button
            OutlineButton(
                title: "Editar perfil",
                action: {
                    showingEditProfile = true
                    HapticFeedback.light.trigger()
                },
                icon: "pencil"
            )
        }
        .cardStyle()
    }
    
    private var statsSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            // Eco Level Progress
            if let user = authViewModel.currentUser {
                ecoLevelSection(user: user)
            }
            
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppDimensions.spacingM) {
                statCard(
                    icon: "leaf.fill",
                    value: "\(authViewModel.currentUser?.ecoPoints ?? 0)",
                    label: "Puntos Eco",
                    color: AppColors.primary
                )
                
                statCard(
                    icon: "square.grid.2x2.fill",
                    value: "\(profileViewModel.totalProductsCount)",
                    label: "Productos",
                    color: .blue
                )
                
                statCard(
                    icon: "heart.fill",
                    value: "\(profileViewModel.donationsCount)",
                    label: "Donaciones",
                    color: .red
                )
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppDimensions.spacingM) {
                statCard(
                    icon: "cart.fill",
                    value: "\(profileViewModel.salesCount)",
                    label: "Ventas",
                    color: .green
                )
                
                statCard(
                    icon: "calendar.badge.clock",
                    value: profileViewModel.memberSinceString,
                    label: "Miembro desde",
                    color: .purple
                )
            }
        }
    }
    
    private func ecoLevelSection(user: User) -> some View {
        VStack(spacing: AppDimensions.spacingM) {
            HStack {
                Text("Nivel Ecológico")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            
            // Current Level
            HStack(spacing: AppDimensions.spacingM) {
                // Level Icon
                VStack {
                    Image(systemName: EcoLevel.levelForPoints(user.ecoPoints).icon)
                        .font(.system(size: 40))
                        .foregroundColor(Color(EcoLevel.levelForPoints(user.ecoPoints).color))
                    
                    Text(EcoLevel.levelForPoints(user.ecoPoints).displayName)
                        .font(AppFonts.bodyMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                // Progress to Next Level
                VStack(alignment: .trailing, spacing: AppDimensions.spacingXS) {
                    if let nextLevel = EcoLevel.levelForPoints(user.ecoPoints).nextLevel {
                        Text("Siguiente: \(nextLevel.displayName)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("\(nextLevel.requiredPoints - user.ecoPoints) puntos restantes")
                            .font(AppFonts.bodySmall)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.primary)
                    } else {
                        Text("¡Nivel máximo!")
                            .font(AppFonts.bodyMedium)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.success)
                    }
                }
            }
            
            // Progress Bar
            if let nextLevel = EcoLevel.levelForPoints(user.ecoPoints).nextLevel {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        let currentLevel = EcoLevel.levelForPoints(user.ecoPoints)
                        let progress = Double(user.ecoPoints - currentLevel.requiredPoints) / 
                                     Double(nextLevel.requiredPoints - currentLevel.requiredPoints)
                        
                        Rectangle()
                            .fill(AppColors.primary)
                            .frame(width: geometry.size.width * max(0, min(1, progress)), height: 8)
                            .cornerRadius(4)
                            .animation(.easeInOut(duration: 1), value: progress)
                    }
                }
                .frame(height: 8)
            }
        }
        .cardStyle()
    }
    
    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: AppDimensions.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(AppFonts.titleMedium)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(label)
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppDimensions.spacingM)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var tabContentSection: some View {
        VStack(spacing: AppDimensions.spacingL) {
            // Tab Selector
            Picker("Profile Tab", selection: $profileViewModel.selectedTab) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    Text(tab.displayName).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Tab Content
            Group {
                switch profileViewModel.selectedTab {
                case .products:
                    productsTabContent
                case .reviews:
                    reviewsTabContent
                case .shipments:
                    shipmentsTabContent
                case .stats:
                    statsTabContent
                }
            }
        }
    }
    
    private var productsTabContent: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            HStack {
                Text("Mis productos")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(profileViewModel.userProducts.count) productos")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if profileViewModel.userProducts.isEmpty {
                emptyStateView(
                    icon: "square.grid.2x2",
                    title: "No tienes productos",
                    subtitle: "Publica tu primer producto y contribuye al medio ambiente"
                )
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppDimensions.spacingM) {
                    ForEach(profileViewModel.userProducts) { product in
                        ProductCardView(product: product) {
                            // TODO: Navigate to product detail
                        }
                    }
                }
            }
        }
    }
    
    private var reviewsTabContent: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            HStack {
                Text("Reseñas recibidas")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(profileViewModel.userReviews.count) reseñas")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if profileViewModel.userReviews.isEmpty {
                emptyStateView(
                    icon: "star",
                    title: "No tienes reseñas",
                    subtitle: "Las reseñas aparecerán aquí cuando otros usuarios califiquen tus productos"
                )
            } else {
                LazyVStack(spacing: AppDimensions.spacingM) {
                    ForEach(profileViewModel.userReviews) { review in
                        ReviewCardView(review: review)
                    }
                }
            }
        }
    }
    
    private var shipmentsTabContent: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Envíos")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            if profileViewModel.userShipments.isEmpty {
                emptyStateView(
                    icon: "shippingbox",
                    title: "No tienes envíos",
                    subtitle: "Aquí aparecerán los envíos de tus productos vendidos"
                )
            } else {
                LazyVStack(spacing: AppDimensions.spacingM) {
                    ForEach(profileViewModel.userShipments) { shipment in
                        ShipmentCardView(shipment: shipment)
                    }
                }
            }
        }
    }
    
    private var statsTabContent: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Estadísticas detalladas")
                .font(AppFonts.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            // TODO: Add detailed statistics charts and metrics
            Text("Próximamente...")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 200)
                .cardStyle()
        }
    }
    
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: AppDimensions.spacingL) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: AppDimensions.spacingS) {
                Text(title)
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .cardStyle()
    }
}

// MARK: - Review Card View
struct ReviewCardView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            HStack {
                // Reviewer Avatar
                AsyncImage(url: URL(string: review.reviewerImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(AppColors.primary.opacity(0.2))
                        .overlay(
                            Text(String(review.reviewerName.prefix(1)))
                                .font(AppFonts.bodyMedium)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primary)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                    Text(review.reviewerName)
                        .font(AppFonts.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack {
                        RatingView(
                            rating: Double(review.rating),
                            size: .small,
                            showValue: false
                        )
                        
                        Text(review.timeAgoString)
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                if review.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppColors.success)
                        .font(.caption)
                }
            }
            
            Text(review.comment)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(4)
        }
        .cardStyle()
    }
}

// MARK: - Shipment Card View
struct ShipmentCardView: View {
    let shipment: Shipment
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            HStack {
                Text(shipment.productTitle)
                    .font(AppFonts.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                StatusBadge(status: shipment.status)
            }
            
            HStack {
                Text("Para: \(shipment.buyerName)")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                if let trackingNumber = shipment.trackingNumber {
                    Text("Seguimiento: \(trackingNumber)")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: ShipmentStatus
    
    var body: some View {
        Text(status.displayName)
            .font(AppFonts.labelSmall)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, AppDimensions.spacingS)
            .padding(.vertical, 4)
            .background(ColorHelper.colorForShipmentStatus(status))
            .cornerRadius(AppDimensions.cornerRadiusS)
    }
}

// MARK: - Settings View Placeholder
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Cerrar sesión") {
                        authViewModel.logout()
                        dismiss()
                        HapticFeedback.light.trigger()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Configuración")
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

// MARK: - Edit Profile View Placeholder
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Editar perfil")
                    .font(AppFonts.headlineLarge)
                
                Text("Próximamente...")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
            .padding(AppDimensions.spacingL)
            .navigationTitle("Editar perfil")
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
    ProfileView()
        .environmentObject(AuthViewModel())
}