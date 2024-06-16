//
//  RealmManager.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import RealmSwift
import Foundation

class RealmManager: ObservableObject {
    @Published var isAuthenticated = false
    private var app: App

    init() {
        // Replace YOUR_APP_ID with your MongoDB Realm App ID
        let appId = "stpdevicesyncservice-agmjocz"
        app = App(id: appId)
        authenticate()
    }

    func authenticate() {
        app.login(credentials: .anonymous) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("Successfully logged in as user: \(user)")
                    self.isAuthenticated = true
                case .failure(let error):
                    print("Failed to log in: \(error.localizedDescription)")
                    self.isAuthenticated = false
                }
            }
        }
    }
}
