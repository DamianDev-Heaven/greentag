//
//  Ranking.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import Foundation

struct Ranking: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let userName: String
    let userImageURL: String?
    let position: Int
    let ecoPoints: Int
    let level: EcoLevel
    let monthlyPoints: Int
    let totalDonations: Int
    let totalSales: Int
    let carbonFootprintReduced: Double // in kg CO2
    let badgesEarned: [EcoBadge]
    let lastActivityDate: Date
    
    var pointsToNextLevel: Int {
        level.nextLevel?.requiredPoints ?? 0 - ecoPoints
    }
    
    var levelProgress: Double {
        let currentLevelPoints = level.requiredPoints
        let nextLevelPoints = level.nextLevel?.requiredPoints ?? currentLevelPoints
        let progressPoints = ecoPoints - currentLevelPoints
        let totalPointsForLevel = nextLevelPoints - currentLevelPoints
        
        return totalPointsForLevel > 0 ? Double(progressPoints) / Double(totalPointsForLevel) : 1.0
    }
    
    var formattedCarbonReduction: String {
        String(format: "%.1f kg CO₂", carbonFootprintReduced)
    }
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        userName: String,
        userImageURL: String? = nil,
        position: Int,
        ecoPoints: Int,
        level: EcoLevel,
        monthlyPoints: Int = 0,
        totalDonations: Int = 0,
        totalSales: Int = 0,
        carbonFootprintReduced: Double = 0.0,
        badgesEarned: [EcoBadge] = [],
        lastActivityDate: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userImageURL = userImageURL
        self.position = position
        self.ecoPoints = ecoPoints
        self.level = level
        self.monthlyPoints = monthlyPoints
        self.totalDonations = totalDonations
        self.totalSales = totalSales
        self.carbonFootprintReduced = carbonFootprintReduced
        self.badgesEarned = badgesEarned
        self.lastActivityDate = lastActivityDate
    }
}

enum EcoLevel: String, CaseIterable, Codable {
    case seedling = "seedling"
    case sprout = "sprout"
    case sapling = "sapling"
    case tree = "tree"
    case forest = "forest"
    case guardian = "guardian"
    
    var displayName: String {
        switch self {
        case .seedling: return "Semilla"
        case .sprout: return "Brote"
        case .sapling: return "Arbolito"
        case .tree: return "Árbol"
        case .forest: return "Bosque"
        case .guardian: return "Guardián"
        }
    }
    
    var icon: String {
        switch self {
        case .seedling: return "leaf.fill"
        case .sprout: return "leaf.arrow.triangle.circlepath"
        case .sapling: return "tree.fill"
        case .tree: return "tree"
        case .forest: return "leaf.circle.fill"
        case .guardian: return "crown.fill"
        }
    }
    
    var color: String {
        switch self {
        case .seedling: return "brown"
        case .sprout: return "green"
        case .sapling: return "mint"
        case .tree: return "teal"
        case .forest: return "cyan"
        case .guardian: return "purple"
        }
    }
    
    var requiredPoints: Int {
        switch self {
        case .seedling: return 0
        case .sprout: return 100
        case .sapling: return 500
        case .tree: return 1500
        case .forest: return 5000
        case .guardian: return 15000
        }
    }
    
    var nextLevel: EcoLevel? {
        switch self {
        case .seedling: return .sprout
        case .sprout: return .sapling
        case .sapling: return .tree
        case .tree: return .forest
        case .forest: return .guardian
        case .guardian: return nil
        }
    }
    
    static func levelForPoints(_ points: Int) -> EcoLevel {
        for level in EcoLevel.allCases.reversed() {
            if points >= level.requiredPoints {
                return level
            }
        }
        return .seedling
    }
}

struct EcoBadge: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: String
    let earnedDate: Date
    let rarity: BadgeRarity
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        icon: String,
        color: String,
        earnedDate: Date = Date(),
        rarity: BadgeRarity = .common
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.earnedDate = earnedDate
        self.rarity = rarity
    }
}

enum BadgeRarity: String, CaseIterable, Codable {
    case common = "common"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    var displayName: String {
        switch self {
        case .common: return "Común"
        case .rare: return "Raro"
        case .epic: return "Épico"
        case .legendary: return "Legendario"
        }
    }
    
    var color: String {
        switch self {
        case .common: return "gray"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "orange"
        }
    }
}

// MARK: - Sample Data
extension Ranking {
    static let sampleRankings: [Ranking] = [
        Ranking(
            userId: "user1",
            userName: "Ana García",
            position: 1,
            ecoPoints: 2850,
            level: .tree,
            monthlyPoints: 420,
            totalDonations: 15,
            totalSales: 8,
            carbonFootprintReduced: 45.6,
            badgesEarned: [
                EcoBadge(name: "Eco Warrior", description: "Primera donación", icon: "leaf.fill", color: "green", rarity: .common),
                EcoBadge(name: "Super Seller", description: "10 ventas completadas", icon: "star.fill", color: "gold", rarity: .rare)
            ]
        ),
        Ranking(
            userId: "user2",
            userName: "Carlos Rodríguez",
            position: 2,
            ecoPoints: 2340,
            level: .tree,
            monthlyPoints: 380,
            totalDonations: 12,
            totalSales: 6,
            carbonFootprintReduced: 38.2,
            badgesEarned: [
                EcoBadge(name: "Green Giver", description: "5 donaciones", icon: "heart.fill", color: "red", rarity: .common)
            ]
        ),
        Ranking(
            userId: "user3",
            userName: "María López",
            position: 3,
            ecoPoints: 1890,
            level: .sapling,
            monthlyPoints: 290,
            totalDonations: 8,
            totalSales: 12,
            carbonFootprintReduced: 31.8,
            badgesEarned: [
                EcoBadge(name: "Fast Trader", description: "Venta en menos de 24h", icon: "bolt.fill", color: "yellow", rarity: .epic)
            ]
        )
    ]
}