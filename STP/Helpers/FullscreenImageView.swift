//
//  FullscreenImageView.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import SwiftUI

struct FullscreenImageView: View {
    var imageDataList: [Data]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(imageDataList, id: \.self) { imageData in
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Images")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}

#Preview {
    let imageDataList: [Data] = {
        if let image = UIImage(systemName: "photo"), let imageData = image.jpegData(compressionQuality: 0.8) {
            return [imageData, imageData, imageData]
        }
        return []
    }()
    
    return FullscreenImageView(imageDataList: imageDataList, isPresented: .constant(true))
}
