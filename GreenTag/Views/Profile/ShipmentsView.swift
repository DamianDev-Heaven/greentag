//
//  ShipmentsView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct ShipmentsView: View {
    @StateObject private var shipmentViewModel = ShipmentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedFilter: ShipmentFilter = .all
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Bar
                filterBar
                
                // Content
                if shipmentViewModel.isLoading {
                    loadingView
                } else if shipmentViewModel.filteredShipments.isEmpty {
                    emptyStateView
                } else {
                    shipmentsList
                }
            }
            .navigationTitle("Envíos")
            .navigationBarTitleDisplayMode(.large)
            .background(AppColors.background.ignoresSafeArea())
            .refreshable {
                await shipmentViewModel.refreshShipments()
            }
        }
        .task {
            if let userId = authViewModel.currentUser?.id {
                await shipmentViewModel.loadShipments(for: userId)
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheetView(selectedFilter: $selectedFilter)
        }
    }
    
    private var filterBar: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppDimensions.spacingM) {
                    ForEach(ShipmentFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            filter: filter,
                            isSelected: selectedFilter == filter,
                            action: {
                                selectedFilter = filter
                                shipmentViewModel.applyFilter(filter)
                                HapticFeedback.light.trigger()
                            }
                        )
                    }
                }
                .padding(.horizontal, AppDimensions.spacingL)
            }
            
            Button(action: {
                showingFilterSheet = true
                HapticFeedback.light.trigger()
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primary)
            }
            .padding(.trailing, AppDimensions.spacingL)
        }
        .padding(.vertical, AppDimensions.spacingM)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
    private var shipmentsList: some View {
        ScrollView {
            LazyVStack(spacing: AppDimensions.spacingM) {
                ForEach(shipmentViewModel.filteredShipments) { shipment in
                    ShipmentCardView(shipment: shipment)
                        .onTapGesture {
                            // Navigate to shipment detail
                        }
                }
            }
            .padding(AppDimensions.spacingL)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppDimensions.spacingL) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Cargando envíos...")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppDimensions.spacingL) {
            Image(systemName: "shippingbox")
                .font(.system(size: 80))
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: AppDimensions.spacingS) {
                Text(emptyStateTitle)
                    .font(AppFonts.headlineMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(emptyStateMessage)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if selectedFilter == .all {
                CustomButton(
                    title: "Explorar productos",
                    style: .secondary,
                    action: {
                        // Navigate to home
                    }
                )
                .frame(maxWidth: 200)
            }
        }
        .padding(AppDimensions.spacingXL)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return "No tienes envíos"
        case .pending: return "No hay envíos pendientes"
        case .inTransit: return "No hay envíos en tránsito"
        case .delivered: return "No hay envíos entregados"
        case .cancelled: return "No hay envíos cancelados"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all: return "Cuando compres o vendas productos, aparecerán aquí"
        case .pending: return "Los envíos pendientes de confirmación aparecerán aquí"
        case .inTransit: return "Los envíos en camino aparecerán aquí"
        case .delivered: return "Los envíos completados aparecerán aquí"
        case .cancelled: return "Los envíos cancelados aparecerán aquí"
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let filter: ShipmentFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppDimensions.spacingS) {
                Image(systemName: filter.icon)
                    .font(.system(size: 14))
                
                Text(filter.displayName)
                    .font(AppFonts.bodyMedium)
            }
            .padding(.horizontal, AppDimensions.spacingM)
            .padding(.vertical, AppDimensions.spacingS)
            .background(
                isSelected ? AppColors.primary : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                isSelected ? .white : AppColors.textPrimary
            )
            .cornerRadius(AppDimensions.cornerRadiusL)
        }
    }
}

// MARK: - Shipment Card View
struct ShipmentCardView: View {
    let shipment: Shipment
    
    var body: some View {
        VStack(spacing: AppDimensions.spacingM) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                    Text("Pedido #\(shipment.id.prefix(8))")
                        .font(AppFonts.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(shipment.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                StatusBadge(status: shipment.status)
            }
            
            // Product Info
            HStack(spacing: AppDimensions.spacingM) {
                AsyncImage(url: URL(string: shipment.product.images.first ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(AppColors.primary.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary)
                        )
                }
                .frame(width: 60, height: 60)
                .cornerRadius(AppDimensions.cornerRadiusM)
                
                VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                    Text(shipment.product.title)
                        .font(AppFonts.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                    
                    Text("Cantidad: \(shipment.quantity)")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(shipment.totalAmount.formatted(.currency(code: "EUR")))
                        .font(AppFonts.titleMedium)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                }
                
                Spacer()
            }
            
            // Shipping Info
            if shipment.status != .pending {
                VStack(spacing: AppDimensions.spacingS) {
                    Divider()
                    
                    HStack {
                        Image(systemName: "truck.box")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Método de envío")
                                .font(AppFonts.labelSmall)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text(shipment.shippingMethod.displayName)
                                .font(AppFonts.bodySmall)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Spacer()
                        
                        if let trackingNumber = shipment.trackingNumber {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Seguimiento")
                                    .font(AppFonts.labelSmall)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text(trackingNumber)
                                    .font(AppFonts.bodySmall)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                }
            }
            
            // Address
            HStack {
                Image(systemName: "location")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dirección de entrega")
                        .font(AppFonts.labelSmall)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(shipment.shippingAddress)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            // Progress
            if shipment.status == .inTransit {
                VStack(spacing: AppDimensions.spacingS) {
                    Divider()
                    
                    HStack {
                        Text("Progreso del envío")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        if let estimatedDelivery = shipment.estimatedDeliveryDate {
                            Text("Entrega estimada: \(estimatedDelivery.formatted(date: .abbreviated, time: .omitted))")
                                .font(AppFonts.labelSmall)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    
                    ShipmentProgressView(status: shipment.status)
                }
            }
            
            // Action Buttons
            if shipment.status == .pending {
                HStack(spacing: AppDimensions.spacingM) {
                    CustomButton(
                        title: "Cancelar",
                        style: .secondary,
                        action: {
                            // Cancel shipment
                        }
                    )
                    
                    CustomButton(
                        title: "Confirmar",
                        action: {
                            // Confirm shipment
                        }
                    )
                }
            } else if shipment.status == .delivered && !shipment.isReviewed {
                CustomButton(
                    title: "Escribir reseña",
                    style: .secondary,
                    action: {
                        // Write review
                    }
                )
            }
        }
        .padding(AppDimensions.spacingL)
        .cardStyle()
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: ShipmentStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.displayName)
                .font(AppFonts.labelSmall)
                .fontWeight(.medium)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, AppDimensions.spacingS)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.1))
        .cornerRadius(AppDimensions.cornerRadiusS)
    }
}

// MARK: - Shipment Progress View
struct ShipmentProgressView: View {
    let status: ShipmentStatus
    
    private let progressSteps: [ShipmentStatus] = [.pending, .inTransit, .delivered]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(progressSteps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 0) {
                    // Step circle
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    // Connection line
                    if index < progressSteps.count - 1 {
                        Rectangle()
                            .fill(step.rawValue <= status.rawValue ? AppColors.success : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
        }
        .frame(height: 20)
    }
    
    private func stepColor(for step: ShipmentStatus) -> Color {
        return step.rawValue <= status.rawValue ? AppColors.success : Color.gray.opacity(0.3)
    }
}

// MARK: - Filter Sheet
struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFilter: ShipmentFilter
    
    var body: some View {
        NavigationView {
            List {
                Section("Filtrar por estado") {
                    ForEach(ShipmentFilter.allCases, id: \.self) { filter in
                        HStack {
                            Image(systemName: filter.icon)
                                .foregroundColor(AppColors.primary)
                                .frame(width: 24)
                            
                            Text(filter.displayName)
                                .font(AppFonts.bodyMedium)
                            
                            Spacer()
                            
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFilter = filter
                            dismiss()
                        }
                    }
                }
            }
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
}

// MARK: - Supporting Types

enum ShipmentFilter: CaseIterable {
    case all
    case pending
    case inTransit
    case delivered
    case cancelled
    
    var displayName: String {
        switch self {
        case .all: return "Todos"
        case .pending: return "Pendientes"
        case .inTransit: return "En tránsito"
        case .delivered: return "Entregados"
        case .cancelled: return "Cancelados"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "shippingbox"
        case .pending: return "clock"
        case .inTransit: return "truck.box"
        case .delivered: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
}

// MARK: - Extensions

extension ShipmentStatus {
    var color: Color {
        switch self {
        case .pending: return AppColors.warning
        case .confirmed: return AppColors.info
        case .inTransit: return AppColors.primary
        case .delivered: return AppColors.success
        case .cancelled: return AppColors.error
        }
    }
}

// MARK: - Preview
#Preview {
    ShipmentsView()
        .environmentObject(AuthViewModel())
}