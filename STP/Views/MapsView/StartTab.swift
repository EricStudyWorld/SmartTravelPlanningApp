//
//  StartTab.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import SwiftUI

struct StartTab: View {

    var body: some View {
        TabView {
            TripMapView()
                .tabItem {
                    Label("TripMap", systemImage: "map")
                }
            DestinationsListView()
                .tabItem {
                    Label("Destinations", systemImage: "globe.desk")
                }
        }
    }
}

#Preview {
    StartTab()
        .modelContainer(Destination.preview)
        .environmentObject(LocationManager())
}
