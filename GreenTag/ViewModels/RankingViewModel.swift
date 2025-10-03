//
//  RankingViewModel.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import Foundation

@MainActor
class RankingViewModel: ObservableObject {
    @Published var rankings: [Ranking] = []
    @Published var currentUserRanking: Ranking?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedPeriod: RankingPeriod = .allTime
    @Published var selectedLeaderboard: LeaderboardType = .ecoPoints
    
    private let userService = UserService()
    
    var filteredRankings: [Ranking] {
        // Sort rankings based on selected leaderboard type
        switch selectedLeaderboard {
        case .ecoPoints:
            return rankings.sorted { $0.ecoPoints > $1.ecoPoints }
        case .monthlyPoints:
            return rankings.sorted { $0.monthlyPoints > $1.monthlyPoints }
        case .donations:
            return rankings.sorted { $0.totalDonations > $1.totalDonations }
        case .sales:
            return rankings.sorted { $0.totalSales > $1.totalSales }
        case .carbonReduction:
            return rankings.sorted { $0.carbonFootprintReduced > $1.carbonFootprintReduced }
        }
    }
    
    var topThreeUsers: [Ranking] {
        Array(filteredRankings.prefix(3))
    }
    
    var remainingUsers: [Ranking] {
        Array(filteredRankings.dropFirst(3))
    }
    
    init() {
        Task {
            await loadRankings()
        }
    }
    
    func loadRankings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let allRankings = try await userService.fetchRankings(
                period: selectedPeriod,
                leaderboard: selectedLeaderboard
            )
            
            self.rankings = allRankings
            updateRankingPositions()
            
        } catch {
            self.errorMessage = "Error al cargar rankings: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshRankings() async {
        await loadRankings()
    }
    
    func loadCurrentUserRanking(userId: String) async {
        do {
            let userRanking = try await userService.fetchUserRanking(
                userId: userId,
                period: selectedPeriod,
                leaderboard: selectedLeaderboard
            )
            self.currentUserRanking = userRanking
        } catch {
            // User might not be in rankings yet
            self.currentUserRanking = nil
        }
    }
    
    func changePeriod(_ period: RankingPeriod) {
        selectedPeriod = period
        Task {
            await loadRankings()
        }
    }
    
    func changeLeaderboard(_ leaderboard: LeaderboardType) {
        selectedLeaderboard = leaderboard
        Task {
            await loadRankings()
        }
    }
    
    private func updateRankingPositions() {
        for (index, _) in filteredRankings.enumerated() {
            rankings[index] = Ranking(
                id: rankings[index].id,
                userId: rankings[index].userId,
                userName: rankings[index].userName,
                userImageURL: rankings[index].userImageURL,
                position: index + 1,
                ecoPoints: rankings[index].ecoPoints,
                level: rankings[index].level,
                monthlyPoints: rankings[index].monthlyPoints,
                totalDonations: rankings[index].totalDonations,
                totalSales: rankings[index].totalSales,
                carbonFootprintReduced: rankings[index].carbonFootprintReduced,
                badgesEarned: rankings[index].badgesEarned,
                lastActivityDate: rankings[index].lastActivityDate
            )
        }
    }
    
    func getRankingValue(for ranking: Ranking) -> String {
        switch selectedLeaderboard {
        case .ecoPoints:
            return "\(ranking.ecoPoints) pts"
        case .monthlyPoints:
            return "\(ranking.monthlyPoints) pts"
        case .donations:
            return "\(ranking.totalDonations) donaciones"
        case .sales:
            return "\(ranking.totalSales) ventas"
        case .carbonReduction:
            return ranking.formattedCarbonReduction
        }
    }
    
    func getTrophyColor(for position: Int) -> Color {
        switch position {
        case 1: return .yellow // Gold
        case 2: return .gray // Silver
        case 3: return Color.orange // Bronze
        default: return .primary
        }
    }
    
    func getTrophyIcon(for position: Int) -> String {
        switch position {
        case 1: return "trophy.fill"
        case 2: return "trophy.fill"
        case 3: return "trophy.fill"
        default: return "person.fill"
        }
    }
}

enum RankingPeriod: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case allTime = "all_time"
    
    var displayName: String {
        switch self {
        case .daily: return "Hoy"
        case .weekly: return "Esta semana"
        case .monthly: return "Este mes"
        case .allTime: return "Todos los tiempos"
        }
    }
}

enum LeaderboardType: String, CaseIterable {
    case ecoPoints = "eco_points"
    case monthlyPoints = "monthly_points"
    case donations = "donations"
    case sales = "sales"
    case carbonReduction = "carbon_reduction"
    
    var displayName: String {
        switch self {
        case .ecoPoints: return "Puntos Eco"
        case .monthlyPoints: return "Puntos del mes"
        case .donations: return "Donaciones"
        case .sales: return "Ventas"
        case .carbonReduction: return "CO₂ reducido"
        }
    }
    
    var icon: String {
        switch self {
        case .ecoPoints: return "leaf.fill"
        case .monthlyPoints: return "calendar"
        case .donations: return "heart.fill"
        case .sales: return "cart.fill"
        case .carbonReduction: return "cloud.fill"
        }
    }
}