//  NewCommentView.swift
//  STP
//
//  Created by Eric Wong on 2/6/2024.
//

import SwiftUI
import RealmSwift

struct NewCommentView: View {
    @Binding var isPresented: Bool
    var placeId: ObjectId
    @State private var text: String = ""
    @State private var showImagePicker = false
    @State private var selectedRecommend: String = ""
    @State private var imageDataList: [Data] = []
    
    // List for the picker
    let recommends = ["Try Next Time", "No"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Comment")) {
                    TextField("Comment", text: $text)
                    
                    Picker("Recommend?", selection: $selectedRecommend) {
                        ForEach(recommends, id: \.self) { recommend in
                            Text(recommend).tag(recommend)
                        }
                    }
                }

                Section(header: Text("Images")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(imageDataList, id: \.self) { imageData in
                                if let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Image(systemName: "plus")
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Comment")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                saveComment()
                isPresented = false
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(imageDataList: $imageDataList)
            }
        }
    }

    private func saveComment() {
        do {
            let realm = try Realm()
            try realm.write {
                let newComment = Comment()
                newComment.placeId = placeId
                newComment.text = text
                newComment.recommends = selectedRecommend
                newComment.imageDataList.append(objectsIn: imageDataList.map { data in
                    let photoData = CommentPhotoData()
                    photoData.data = data
                    return photoData
                })
                realm.add(newComment)
                
                // Add the new comment to the corresponding place
                if let place = realm.object(ofType: Place.self, forPrimaryKey: placeId) {
                    place.comments.append(newComment)
                }
            }
        } catch {
            print("Error saving comment: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NewCommentView(isPresented: .constant(true), placeId: ObjectId.generate())
}
