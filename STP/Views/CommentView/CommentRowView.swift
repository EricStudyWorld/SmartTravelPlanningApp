//  CommentRowView.swift
//  STP
//
//  Created by Eric Wong on 2/6/2024.
//

import SwiftUI
import RealmSwift

struct CommentRowView: View {
    @ObservedRealmObject var comment: Comment
    @State private var showFullscreenImage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(comment.text)
                .font(.body)
            
            Text(formatDate(comment.date))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(comment.imageDataList, id: \.id) { photoData in
                        if let uiImage = UIImage(data: photoData.data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    showFullscreenImage = true
                                }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 5)
        .sheet(isPresented: $showFullscreenImage) {
            FullscreenImageView(imageDataList: comment.imageDataList.map { $0.data }, isPresented: $showFullscreenImage)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

#Preview {
    let comment = Comment()
    comment.text = "This is a sample comment."
    comment.date = Date()
    
    // Mock image data for preview
    if let image = UIImage(systemName: "photo"), let imageData = image.jpegData(compressionQuality: 0.8) {
        let photoData = CommentPhotoData()
        photoData.data = imageData
        comment.imageDataList.append(photoData)
    }
    
    return CommentRowView(comment: comment)
}
