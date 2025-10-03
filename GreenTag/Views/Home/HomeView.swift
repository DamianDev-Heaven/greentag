//
//  HomeView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddProduct = false
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDimensions.spacingL) {
                    // Header with search
                    headerSection
                    
                    // Featured Products
                    if !homeViewModel.featuredProducts.isEmpty {
                        featuredSection
                    }
                    
                    // Filters
                    filtersSection
                    
                    // Products Grid
                    productsSection
                }
                .padding(.horizontal, AppDimensions.spacingM)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    headerToolbar
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddProduct = true
                        HapticFeedback.light.trigger()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .refreshable {
                await homeViewModel.refreshProducts()
            }
            .background(AppColors.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showingAddProduct) {
            AddProductView()
        }
        .sheet(isPresented: $showingFilters) {
            FiltersView(homeViewModel: homeViewModel)
        }
        .task {
            if homeViewModel.products.isEmpty {
                await homeViewModel.loadProducts()
            }
        }
    }
    
    private var headerToolbar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hola, \(authViewModel.currentUser?.firstName ?? "Usuario")")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                
                Text("GreenTag")
                    .font(AppFonts.headlineSmall)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
            }
            
            Spacer()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            // Search Bar
            SearchTextField(
                searchText: $homeViewModel.searchText,
                placeholder: "Buscar productos ecológicos...",
                onSearchCommit: {
                    // Search functionality handled by filteredProducts
                }
            )
            
            // Quick Stats
            if let user = authViewModel.currentUser {
                quickStatsView(user: user)
            }
        }
        .padding(.top, AppDimensions.spacingS)
    }
    
    private func quickStatsView(user: User) -> some View {
        HStack {
            statItem(
                icon: "leaf.fill",
                value: "\(user.ecoPoints)",
                label: "Puntos Eco",
                color: AppColors.primary
            )
            
            Divider()
                .frame(height: 30)
            
            statItem(
                icon: "star.fill",
                value: user.displayRating,
                label: "Calificación",
                color: .orange
            )
            
            Divider()
                .frame(height: 30)
            
            statItem(
                icon: "heart.fill",
                value: "12", // TODO: Get from user data
                label: "Favoritos",
                color: .red
            )
        }
        .padding(AppDimensions.spacingM)
        .cardStyle()
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: AppDimensions.spacingXS) {
            HStack(spacing: AppDimensions.spacingXS) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(value)
                    .font(AppFonts.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Text(label)
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            HStack {
                Text("Destacados")
                    .font(AppFonts.headlineSmall)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button("Ver todos") {
                    // TODO: Navigate to all featured products
                    HapticFeedback.light.trigger()
                }
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.primary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppDimensions.spacingM) {
                    ForEach(homeViewModel.featuredProducts) { product in
                        FeaturedProductCard(product: product) {
                            // TODO: Navigate to product detail
                        }
                    }
                }
                .padding(.horizontal, AppDimensions.spacingM)
            }
            .padding(.horizontal, -AppDimensions.spacingM)
        }
    }
    
    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppDimensions.spacingM) {
                // Filter Button
                Button(action: {
                    showingFilters = true
                    HapticFeedback.light.trigger()
                }) {
                    HStack(spacing: AppDimensions.spacingS) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filtros")
                    }
                    .font(AppFonts.bodyMedium)
                    .padding(.horizontal, AppDimensions.spacingM)
                    .padding(.vertical, AppDimensions.spacingS)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(AppDimensions.cornerRadiusL)
                }
                
                // Category Filters
                ForEach(ProductCategory.allCases.prefix(5), id: \.self) { category in
                    categoryFilterButton(category)
                }
                
                // Donation Filter
                donationFilterButton
            }
            .padding(.horizontal, AppDimensions.spacingM)
        }
        .padding(.horizontal, -AppDimensions.spacingM)
    }
    
    private func categoryFilterButton(_ category: ProductCategory) -> some View {
        Button(action: {
            if homeViewModel.selectedCategory == category {
                homeViewModel.selectedCategory = nil
            } else {
                homeViewModel.selectedCategory = category
            }
            HapticFeedback.light.trigger()
        }) {
            HStack(spacing: AppDimensions.spacingS) {
                Image(systemName: category.icon)
                Text(category.displayName)
            }
            .font(AppFonts.bodyMedium)
            .padding(.horizontal, AppDimensions.spacingM)
            .padding(.vertical, AppDimensions.spacingS)
            .background(
                homeViewModel.selectedCategory == category ?
                AppColors.primary : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                homeViewModel.selectedCategory == category ?
                .white : AppColors.textPrimary
            )
            .cornerRadius(AppDimensions.cornerRadiusL)
        }
    }
    
    private var donationFilterButton: some View {
        Button(action: {
            homeViewModel.showDonationsOnly.toggle()
            HapticFeedback.light.trigger()
        }) {
            HStack(spacing: AppDimensions.spacingS) {
                Image(systemName: "heart.fill")
                Text("Gratis")
            }
            .font(AppFonts.bodyMedium)
            .padding(.horizontal, AppDimensions.spacingM)
            .padding(.vertical, AppDimensions.spacingS)
            .background(
                homeViewModel.showDonationsOnly ?
                AppColors.success : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                homeViewModel.showDonationsOnly ?
                .white : AppColors.textPrimary
            )
            .cornerRadius(AppDimensions.cornerRadiusL)
        }
    }
    
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            HStack {
                Text("Productos disponibles")
                    .font(AppFonts.headlineSmall)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(homeViewModel.filteredProducts.count) productos")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if homeViewModel.isLoading {
                loadingView
            } else if homeViewModel.filteredProducts.isEmpty {
                emptyStateView
            } else {
                productsGrid
            }
        }
    }
    
    private var productsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: AppDimensions.spacingM) {
            ForEach(homeViewModel.filteredProducts) { product in
                ProductCardView(product: product) {
                    // TODO: Navigate to product detail
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppDimensions.spacingL) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Cargando productos...")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppDimensions.spacingL) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: AppDimensions.spacingS) {
                Text("No se encontraron productos")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Intenta ajustar tus filtros de búsqueda")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            SecondaryButton(
                title: "Limpiar filtros",
                action: {
                    homeViewModel.clearFilters()
                    HapticFeedback.light.trigger()
                }
            )
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

// MARK: - Filters View
struct FiltersView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppDimensions.spacingL) {
                // Sort Options
                VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
                    Text("Ordenar por")
                        .font(AppFonts.titleLarge)
                        .fontWeight(.semibold)
                    
                    ForEach(SortOption.allCases, id: \.self) { option in
                        sortOptionRow(option)
                    }
                }
                .cardStyle()
                
                Spacer()
                
                // Apply Button
                PrimaryButton(
                    title: "Aplicar filtros",
                    action: {
                        dismiss()
                        HapticFeedback.success.trigger()
                    }
                )
            }
            .padding(AppDimensions.spacingL)
            .navigationTitle("Filtros")
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
    
    private func sortOptionRow(_ option: SortOption) -> some View {
        Button(action: {
            homeViewModel.sortOption = option
            HapticFeedback.light.trigger()
        }) {
            HStack {
                Text(option.displayName)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if homeViewModel.sortOption == option {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.vertical, AppDimensions.spacingS)
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}