//
//  GreenTagApp.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI

@main
struct GreenTagApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}