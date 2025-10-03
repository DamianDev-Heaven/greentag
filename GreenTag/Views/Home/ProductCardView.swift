//
//  ProductCardView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    let onTap: () -> Void
    @State private var isFavorite = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                // Product Image
                productImageView
                
                // Product Info
                productInfoView
                
                // Seller Info
                sellerInfoView
            }
            .padding(AppDimensions.spacingM)
            .background(Color.white)
            .cornerRadius(AppDimensions.cornerRadiusM)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var productImageView: some View {
        ZStack(alignment: .topTrailing) {
            // Product Image
            AsyncImage(url: URL(string: product.primaryImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(AppDimensions.cornerRadiusS)
            
            // Favorite Button
            Button(action: {
                isFavorite.toggle()
                HapticFeedback.light.trigger()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isFavorite ? .red : .white)
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(AppDimensions.spacingS)
            
            // Donation Badge
            if product.isDonation {
                VStack {
                    Spacer()
                    
                    HStack {
                        Text("GRATIS")
                            .font(AppFonts.labelSmall)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppDimensions.spacingS)
                            .padding(.vertical, 4)
                            .background(AppColors.success)
                            .cornerRadius(AppDimensions.cornerRadiusS)
                        
                        Spacer()
                    }
                }
                .padding(AppDimensions.spacingS)
            }
        }
    }
    
    private var productInfoView: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
            // Title
            Text(product.title)
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Price
            Text(product.formattedPrice)
                .font(AppFonts.titleMedium)
                .fontWeight(.bold)
                .foregroundColor(product.isDonation ? AppColors.success : AppColors.primary)
            
            // Category and Condition
            HStack {
                CategoryBadge(category: product.category)
                
                Spacer()
                
                ConditionBadge(condition: product.condition)
            }
            
            // Location
            HStack {
                Image(systemName: "location")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(product.location.displayAddress)
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                
                Spacer()
            }
        }
    }
    
    private var sellerInfoView: some View {
        HStack {
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
                            .font(AppFonts.bodySmall)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primary)
                    )
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())
            
            // Seller Name
            Text(product.sellerName)
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
            
            Spacer()
            
            // Rating
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
                
                Text(String(format: "%.1f", product.sellerRating))
                    .font(AppFonts.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - Featured Product Card
struct FeaturedProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppDimensions.spacingS) {
                // Product Image
                AsyncImage(url: URL(string: product.primaryImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 200, height: 120)
                .clipped()
                .cornerRadius(AppDimensions.cornerRadiusS)
                
                // Product Info
                VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                    Text(product.title)
                        .font(AppFonts.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(product.formattedPrice)
                        .font(AppFonts.bodyMedium)
                        .fontWeight(.bold)
                        .foregroundColor(product.isDonation ? AppColors.success : AppColors.primary)
                    
                    HStack {
                        Text(product.sellerName)
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        RatingView(
                            rating: product.sellerRating,
                            size: .small,
                            showValue: false
                        )
                    }
                }
                .padding(.horizontal, AppDimensions.spacingS)
            }
            .frame(width: 200)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: ProductCategory
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: 10, weight: .medium))
            
            Text(category.displayName)
                .font(AppFonts.labelSmall)
        }
        .foregroundColor(ColorHelper.colorForCategory(category))
        .padding(.horizontal, AppDimensions.spacingS)
        .padding(.vertical, 4)
        .background(ColorHelper.colorForCategory(category).opacity(0.1))
        .cornerRadius(AppDimensions.cornerRadiusS)
    }
}

// MARK: - Condition Badge
struct ConditionBadge: View {
    let condition: ProductCondition
    
    var body: some View {
        Text(condition.displayName)
            .font(AppFonts.labelSmall)
            .foregroundColor(ColorHelper.colorForCondition(condition))
            .padding(.horizontal, AppDimensions.spacingS)
            .padding(.vertical, 4)
            .background(ColorHelper.colorForCondition(condition).opacity(0.1))
            .cornerRadius(AppDimensions.cornerRadiusS)
    }
}

// MARK: - Product Grid View
struct ProductGridView: View {
    let products: [Product]
    let onProductTap: (Product) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: AppDimensions.spacingM) {
            ForEach(products) { product in
                ProductCardView(product: product) {
                    onProductTap(product)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: AppDimensions.spacingL) {
        ProductCardView(product: Product.sampleProducts[0]) {
            print("Product tapped")
        }
        
        FeaturedProductCard(product: Product.sampleProducts[1]) {
            print("Featured product tapped")
        }
        
        Spacer()
    }
    .padding()
    .background(AppColors.background)
}