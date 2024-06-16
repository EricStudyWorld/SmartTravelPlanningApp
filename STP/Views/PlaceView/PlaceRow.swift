//  PlaceRow.swift
//  STP
//
//  Created by Eric Wong on 1/6/2024.
//

import SwiftUI
import RealmSwift

struct PlaceRow: View {
    @ObservedRealmObject var place: Place
    @State private var isEditing = false
    @State private var showPlaceDetail = false // State to manage PlaceDetail presentation

    var body: some View {
        HStack {
            if let firstImageData = place.imageDataList.first?.data, let uiImage = UIImage(data: firstImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }

            Text(place.name)

            Spacer()
            
            // Favorite button
            Button(action: {
                $place.isFavorite.wrappedValue.toggle()
            }) {
                Image(systemName: place.isFavorite ? "bookmark.fill" : "bookmark")
                    .foregroundColor(place.isFavorite ? .yellow : .gray)
            }
            
            // Detail button
            Button(action: {
                showPlaceDetail.toggle()
            }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
            }
        }
        .contextMenu {
            Button("Edit Place") {
                isEditing = true
            }
            
            Button("Delete Place", role: .destructive) {
                deletePlace()
            }
        }
        .sheet(isPresented: $isEditing) {
            NewPlaceView(isPresented: $isEditing, place: place)
        }
        .sheet(isPresented: $showPlaceDetail) {
            PlaceDetail(place: place)
        }
    }

    private func deletePlace() {
        do {
            let realm = try Realm()
            // Thaw the place object before attempting to delete it
            guard let livePlace = place.thaw() else { return }
            try realm.write {
                realm.delete(livePlace)
            }
        } catch {
            print("Error deleting place: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let place = Place()
    place.name = "Sample Place"
    place.address = "123 Main St"
    place.country = "Country"
    place.descriptionText = "A beautiful place to visit."
    place.types = "Type"
    place.isFavorite = false
    
    // Mock image data for preview
    if let image = UIImage(systemName: "photo"), let imageData = image.jpegData(compressionQuality: 0.8) {
        let photoData = PhotoData()
        photoData.data = imageData
        place.imageDataList.append(photoData)
    }
    
    return PlaceRow(place: place)
}
