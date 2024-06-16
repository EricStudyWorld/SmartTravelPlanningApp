//
//  STPApp.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import SwiftUI
import RealmSwift

@main
struct STPApp: SwiftUI.App {
    @StateObject var biometricModel = BiometricModel()
    @StateObject private var realmManager = RealmManager()
    @StateObject private var locationManager = LocationManager()
    
    init() {
        performMigration()
    }
    
    var body: some Scene {
        WindowGroup {
            if biometricModel.isAuthenticated {
                if realmManager.isAuthenticated {
                    TabView {
                        Group {
                            DailyHome()
                                .tabItem {
                                    Label("Plan", systemImage: "menucard.fill")
                                }
                            if locationManager.isAuthorized {
                                StartTab()
                                    .tabItem {
                                        Label("Map", systemImage: "map.circle")
                                    }
                            } else {
                                LocationDeniedView()
                                    .tabItem {
                                        Label("Location Denied", systemImage: "location.slash")
                                    }
                            }
                            BERTView()
                                .tabItem {
                                    Label("Analzye", systemImage: "doc.viewfinder.fill")
                                }
                        }
                        .toolbarBackground(.taskColor1.opacity(0.8), for: .tabBar)
                        .toolbarBackground(.visible, for: .tabBar)
                        .toolbarColorScheme(.dark, for: .tabBar)
                    }
                    .onAppear {
                        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
                        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                    }
                    .environmentObject(locationManager)
                } else {
                    ProgressView("Authenticating...")
                        .onAppear {
                            realmManager.authenticate()
                        }
                }
            } else {
                AuthenticationView(biometricModel: biometricModel)
            }
        }
        .modelContainer(for: Destination.self)
    }
}
