//
//  RatingView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct RatingView: View {
    let rating: Double
    let maxRating: Int = 5
    var size: RatingSize = .medium
    var style: RatingStyle = .filled
    var showValue: Bool = true
    var isInteractive: Bool = false
    @Binding var selectedRating: Int
    
    init(
        rating: Double,
        size: RatingSize = .medium,
        style: RatingStyle = .filled,
        showValue: Bool = true
    ) {
        self.rating = rating
        self.size = size
        self.style = style
        self.showValue = showValue
        self.isInteractive = false
        self._selectedRating = .constant(0)
    }
    
    init(
        selectedRating: Binding<Int>,
        size: RatingSize = .medium,
        style: RatingStyle = .filled
    ) {
        self.rating = 0
        self.size = size
        self.style = style
        self.showValue = false
        self.isInteractive = true
        self._selectedRating = selectedRating
    }
    
    var body: some View {
        HStack(spacing: size.spacing) {
            // Stars
            HStack(spacing: size.starSpacing) {
                ForEach(1...maxRating, id: \.self) { index in
                    starView(for: index)
                        .onTapGesture {
                            if isInteractive {
                                selectedRating = index
                                HapticFeedback.light.trigger()
                            }
                        }
                }
            }
            
            // Rating value text
            if showValue && !isInteractive {
                Text(String(format: "%.1f", rating))
                    .font(size.font)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    @ViewBuilder
    private func starView(for index: Int) -> some View {
        let currentRating = isInteractive ? Double(selectedRating) : rating
        let fillAmount = min(max(currentRating - Double(index - 1), 0), 1)
        
        ZStack {
            // Background star
            Image(systemName: style.emptyIcon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(style.emptyColor)
            
            // Filled star
            Image(systemName: style.filledIcon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(style.filledColor)
                .mask(
                    Rectangle()
                        .size(width: size.iconSize * fillAmount, height: size.iconSize)
                        .offset(x: -size.iconSize * (1 - fillAmount) / 2)
                )
        }
        .scaleEffect(isInteractive && selectedRating >= index ? 1.1 : 1.0)
        .animation(AppAnimations.springAnimation, value: selectedRating)
    }
}

// MARK: - Rating Sizes
extension RatingView {
    enum RatingSize {
        case small
        case medium
        case large
        case extraLarge
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            case .extraLarge: return 24
            }
        }
        
        var starSpacing: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 3
            case .large: return 4
            case .extraLarge: return 5
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            case .extraLarge: return 10
            }
        }
        
        var font: Font {
            switch self {
            case .small: return AppFonts.bodySmall
            case .medium: return AppFonts.bodyMedium
            case .large: return AppFonts.bodyLarge
            case .extraLarge: return AppFonts.titleMedium
            }
        }
    }
}

// MARK: - Rating Styles
extension RatingView {
    enum RatingStyle {
        case filled
        case outlined
        case hearts
        
        var filledIcon: String {
            switch self {
            case .filled, .outlined: return "star.fill"
            case .hearts: return "heart.fill"
            }
        }
        
        var emptyIcon: String {
            switch self {
            case .filled: return "star"
            case .outlined: return "star"
            case .hearts: return "heart"
            }
        }
        
        var filledColor: Color {
            switch self {
            case .filled, .outlined: return .orange
            case .hearts: return .red
            }
        }
        
        var emptyColor: Color {
            return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Rating Summary View
struct RatingSummaryView: View {
    let averageRating: Double
    let totalReviews: Int
    let size: RatingView.RatingSize = .medium
    
    var body: some View {
        HStack(spacing: AppDimensions.spacingS) {
            RatingView(
                rating: averageRating,
                size: size,
                showValue: false
            )
            
            Text("(\(totalReviews))")
                .font(size.font)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Detailed Rating View
struct DetailedRatingView: View {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [Int] // Array of 5 elements representing count for each star rating
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            // Overall rating
            HStack {
                VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                    Text(String(format: "%.1f", averageRating))
                        .font(AppFonts.displayMedium)
                        .fontWeight(.bold)
                    
                    RatingView(
                        rating: averageRating,
                        size: .large,
                        showValue: false
                    )
                    
                    Text("\(totalReviews) reseñas")
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
            
            // Rating distribution
            VStack(spacing: AppDimensions.spacingS) {
                ForEach((1...5).reversed(), id: \.self) { rating in
                    ratingDistributionRow(for: rating)
                }
            }
        }
        .padding(AppDimensions.spacingL)
        .cardStyle()
    }
    
    private func ratingDistributionRow(for rating: Int) -> some View {
        let count = ratingDistribution.indices.contains(rating - 1) ? ratingDistribution[rating - 1] : 0
        let percentage = totalReviews > 0 ? Double(count) / Double(totalReviews) : 0
        
        return HStack(spacing: AppDimensions.spacingM) {
            // Star rating
            HStack(spacing: 2) {
                Text("\(rating)")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
            }
            .frame(width: 30, alignment: .leading)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(.orange)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.5), value: percentage)
                }
            }
            .frame(height: 8)
            
            // Count
            Text("\(count)")
                .font(AppFonts.bodySmall)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Interactive Rating Input
struct RatingInputView: View {
    @Binding var rating: Int
    let title: String
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            HStack {
                Text(title)
                    .font(AppFonts.titleMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                if isRequired {
                    Text("*")
                        .font(AppFonts.titleMedium)
                        .foregroundColor(AppColors.error)
                }
                
                Spacer()
            }
            
            RatingView(selectedRating: $rating, size: .large)
            
            if rating > 0 {
                Text(ratingDescription)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .animation(.easeInOut, value: rating)
            }
        }
    }
    
    private var ratingDescription: String {
        switch rating {
        case 1: return "Muy malo"
        case 2: return "Malo"
        case 3: return "Regular"
        case 4: return "Bueno"
        case 5: return "Excelente"
        default: return ""
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: AppDimensions.spacingXL) {
        RatingView(rating: 4.3, size: .small)
        RatingView(rating: 4.3, size: .medium)
        RatingView(rating: 4.3, size: .large)
        RatingView(rating: 4.3, size: .extraLarge)
        
        RatingSummaryView(averageRating: 4.3, totalReviews: 127)
        
        RatingInputView(rating: .constant(4), title: "Califica este producto")
        
        DetailedRatingView(
            averageRating: 4.3,
            totalReviews: 150,
            ratingDistribution: [5, 8, 12, 45, 80]
        )
        
        Spacer()
    }
    .padding()
}