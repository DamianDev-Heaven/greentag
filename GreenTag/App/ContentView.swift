//
//  ContentView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
            
            RankingsView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Rankings")
                }
            
            AddProductView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Publicar")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
        }
        .accentColor(AppColors.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}