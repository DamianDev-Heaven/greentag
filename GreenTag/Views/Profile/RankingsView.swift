//
//  RankingsView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct RankingsView: View {
    @StateObject private var rankingViewModel = RankingViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppDimensions.spacingL) {
                    // Header Section
                    headerSection
                    
                    // Leaderboard Selector
                    leaderboardSelector
                    
                    // Period Selector
                    periodSelector
                    
                    // Top 3 Podium
                    if !rankingViewModel.topThreeUsers.isEmpty {
                        podiumSection
                    }
                    
                    // Rankings List
                    rankingsList
                    
                    // Current User Ranking
                    if let currentUserRanking = rankingViewModel.currentUserRanking {
                        currentUserSection(currentUserRanking)
                    }
                }
                .padding(AppDimensions.spacingL)
            }
            .navigationTitle("Rankings")
            .navigationBarTitleDisplayMode(.large)
            .background(AppColors.background.ignoresSafeArea())
            .refreshable {
                await rankingViewModel.refreshRankings()
            }
        }
        .task {
            await rankingViewModel.loadRankings()
            if let userId = authViewModel.currentUser?.id {
                await rankingViewModel.loadCurrentUserRanking(userId: userId)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppDimensions.spacingM) {
            // Trophy Icon
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            VStack(spacing: AppDimensions.spacingS) {
                Text("Rankings Ecológicos")
                    .font(AppFonts.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Descubre quiénes están liderando la revolución ecológica")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .cardStyle()
    }
    
    private var leaderboardSelector: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Tipo de ranking")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppDimensions.spacingM) {
                    ForEach(LeaderboardType.allCases, id: \.self) { type in
                        leaderboardButton(type)
                    }
                }
                .padding(.horizontal, AppDimensions.spacingM)
            }
            .padding(.horizontal, -AppDimensions.spacingM)
        }
    }
    
    private func leaderboardButton(_ type: LeaderboardType) -> some View {
        Button(action: {
            rankingViewModel.changeLeaderboard(type)
            HapticFeedback.light.trigger()
        }) {
            HStack(spacing: AppDimensions.spacingS) {
                Image(systemName: type.icon)
                    .font(.system(size: 16))
                
                Text(type.displayName)
                    .font(AppFonts.bodyMedium)
            }
            .padding(.horizontal, AppDimensions.spacingM)
            .padding(.vertical, AppDimensions.spacingS)
            .background(
                rankingViewModel.selectedLeaderboard == type ?
                AppColors.primary : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                rankingViewModel.selectedLeaderboard == type ?
                .white : AppColors.textPrimary
            )
            .cornerRadius(AppDimensions.cornerRadiusL)
        }
    }
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Período")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            Picker("Period", selection: $rankingViewModel.selectedPeriod) {
                ForEach(RankingPeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: rankingViewModel.selectedPeriod) { newPeriod in
                rankingViewModel.changePeriod(newPeriod)
            }
        }
        .cardStyle()
    }
    
    private var podiumSection: some View {
        VStack(spacing: AppDimensions.spacingL) {
            Text("🏆 Top 3")
                .font(AppFonts.headlineMedium)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(alignment: .bottom, spacing: AppDimensions.spacingM) {
                // Second place
                if rankingViewModel.topThreeUsers.count > 1 {
                    podiumUser(rankingViewModel.topThreeUsers[1], position: 2)
                }
                
                // First place
                if !rankingViewModel.topThreeUsers.isEmpty {
                    podiumUser(rankingViewModel.topThreeUsers[0], position: 1)
                }
                
                // Third place
                if rankingViewModel.topThreeUsers.count > 2 {
                    podiumUser(rankingViewModel.topThreeUsers[2], position: 3)
                }
            }
        }
        .cardStyle()
    }
    
    private func podiumUser(_ ranking: Ranking, position: Int) -> some View {
        VStack(spacing: AppDimensions.spacingM) {
            // Trophy
            Image(systemName: rankingViewModel.getTrophyIcon(for: position))
                .font(.system(size: position == 1 ? 40 : 30))
                .foregroundColor(rankingViewModel.getTrophyColor(for: position))
            
            // User Avatar
            AsyncImage(url: URL(string: ranking.userImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .overlay(
                        Text(String(ranking.userName.prefix(1)))
                            .font(position == 1 ? AppFonts.titleLarge : AppFonts.titleMedium)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    )
            }
            .frame(width: position == 1 ? 80 : 60, height: position == 1 ? 80 : 60)
            .clipShape(Circle())
            
            VStack(spacing: AppDimensions.spacingXS) {
                // Name
                Text(ranking.userName)
                    .font(position == 1 ? AppFonts.titleMedium : AppFonts.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Level Badge
                HStack(spacing: 4) {
                    Image(systemName: ranking.level.icon)
                        .font(.system(size: 12))
                        .foregroundColor(Color(ranking.level.color))
                    
                    Text(ranking.level.displayName)
                        .font(AppFonts.labelSmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Value
                Text(rankingViewModel.getRankingValue(for: ranking))
                    .font(position == 1 ? AppFonts.bodyMedium : AppFonts.bodySmall)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
            }
            
            // Podium Height
            Rectangle()
                .fill(rankingViewModel.getTrophyColor(for: position).opacity(0.3))
                .frame(height: position == 1 ? 60 : position == 2 ? 40 : 30)
                .cornerRadius(AppDimensions.cornerRadiusS, corners: [.topLeft, .topRight])
        }
        .frame(maxWidth: .infinity)
    }
    
    private var rankingsList: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            HStack {
                Text("Clasificación completa")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if rankingViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if rankingViewModel.isLoading {
                loadingView
            } else if rankingViewModel.remainingUsers.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: AppDimensions.spacingM) {
                    ForEach(rankingViewModel.filteredRankings) { ranking in
                        RankingRowView(
                            ranking: ranking,
                            rankingValue: rankingViewModel.getRankingValue(for: ranking),
                            isCurrentUser: ranking.userId == authViewModel.currentUser?.id
                        )
                    }
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppDimensions.spacingL) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Cargando rankings...")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppDimensions.spacingL) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: AppDimensions.spacingS) {
                Text("No hay rankings disponibles")
                    .font(AppFonts.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Los rankings se actualizan con la actividad de los usuarios")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private func currentUserSection(_ ranking: Ranking) -> some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            Text("Tu posición")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            RankingRowView(
                ranking: ranking,
                rankingValue: rankingViewModel.getRankingValue(for: ranking),
                isCurrentUser: true,
                showHighlight: true
            )
        }
        .cardStyle()
    }
}

// MARK: - Ranking Row View
struct RankingRowView: View {
    let ranking: Ranking
    let rankingValue: String
    let isCurrentUser: Bool
    var showHighlight: Bool = false
    
    var body: some View {
        HStack(spacing: AppDimensions.spacingM) {
            // Position
            Text("#\(ranking.position)")
                .font(AppFonts.titleMedium)
                .fontWeight(.bold)
                .foregroundColor(
                    ranking.position <= 3 ? rankingViewModel.getTrophyColor(for: ranking.position) : AppColors.textPrimary
                )
                .frame(width: 40, alignment: .leading)
            
            // User Avatar
            AsyncImage(url: URL(string: ranking.userImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .overlay(
                        Text(String(ranking.userName.prefix(1)))
                            .font(AppFonts.bodyMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primary)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // User Info
            VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                HStack {
                    Text(ranking.userName)
                        .font(AppFonts.titleMedium)
                        .fontWeight(isCurrentUser ? .bold : .semibold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    if isCurrentUser {
                        Text("(Tú)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.primary)
                    }
                }
                
                HStack(spacing: AppDimensions.spacingS) {
                    // Level Badge
                    HStack(spacing: 4) {
                        Image(systemName: ranking.level.icon)
                            .font(.system(size: 12))
                            .foregroundColor(Color(ranking.level.color))
                        
                        Text(ranking.level.displayName)
                            .font(AppFonts.labelSmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    // Activity Indicator
                    if Calendar.current.isDateInToday(ranking.lastActivityDate) {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(AppColors.success)
                                .frame(width: 6, height: 6)
                            
                            Text("Activo hoy")
                                .font(AppFonts.labelSmall)
                                .foregroundColor(AppColors.success)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Value
            VStack(alignment: .trailing, spacing: AppDimensions.spacingXS) {
                Text(rankingValue)
                    .font(AppFonts.titleMedium)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                
                if ranking.monthlyPoints > 0 {
                    Text("+\(ranking.monthlyPoints) este mes")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(AppColors.success)
                }
            }
        }
        .padding(AppDimensions.spacingM)
        .background(
            showHighlight ? AppColors.primary.opacity(0.1) : Color.white
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppDimensions.cornerRadiusM)
                .stroke(
                    isCurrentUser ? AppColors.primary : Color.clear,
                    lineWidth: isCurrentUser ? 2 : 0
                )
        )
        .cornerRadius(AppDimensions.cornerRadiusM)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // Helper to access rankingViewModel from static context
    private var rankingViewModel: RankingViewModel {
        return RankingViewModel()
    }
}

// MARK: - Preview
#Preview {
    RankingsView()
        .environmentObject(AuthViewModel())
}