//
//  AuthenticationView.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import Foundation
import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var biometricModel: BiometricModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("Cover")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            
            Spacer()
            
            Text("Welcome to\n Smart Travel Planning")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.bottom, 20)
            
            Button(action: {
                biometricModel.evaluatePolicy()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Authenticate")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            
            Spacer()
            
            Text("version 1.0")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
