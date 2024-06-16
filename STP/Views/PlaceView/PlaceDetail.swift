//
//  PlaceDetail.swift
//  STP
//
//  Created by Eric Wong on 1/6/2024.
//

import SwiftUI
import UIKit
import RealmSwift
import MapKit

struct PlaceDetail: View {
    @ObservedRealmObject var place: Place
    @State private var selectedImageIndex = 0
    @State private var selectedTab = 0

    let standardImageSize: CGFloat = 300
    let tabTitles = ["Details", "Comments", "Reviews", "Map"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if !place.imageDataList.isEmpty {
                    TabView(selection: $selectedImageIndex) {
                        ForEach(Array(place.imageDataList.enumerated()), id: \.offset) { index, photoData in
                            if let uiImage = UIImage(data: photoData.data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: standardImageSize, height: standardImageSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .tag(index)
                                    .transition(.slide)
                                    .animation(.easeInOut, value: selectedImageIndex)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: standardImageSize)
                } else {
                    Text("No images available")
                        .frame(height: standardImageSize)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                HStack {
                    Text(place.name)
                        .font(.title2)
                        .padding(.top)

                    // Button to copy place.name to clipboard
                    Button(action: {
                        UIPasteboard.general.string = place.name
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Favorite button
                    Button(action: {
                        $place.isFavorite.wrappedValue.toggle()
                    }) {
                        Image(systemName: place.isFavorite ? "bookmark.fill" : "bookmark")
                            .foregroundColor(place.isFavorite ? .yellow : .gray)
                    }
                }

                HStack {
                    Text(place.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Button to copy place.address to clipboard
                    Button(action: {
                        UIPasteboard.general.string = place.address
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(place.country)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Picker to act as the tab selector
                Picker("Select Tab", selection: $selectedTab) {
                    ForEach(0..<tabTitles.count, id: \.self) { index in
                        Text(tabTitles[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Conditional content based on selected tab
                if selectedTab == 0 {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Details")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text(place.types)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(place.descriptionText)
                            .font(.subheadline)
                    }
                    .padding()
                } else if selectedTab == 1 {
                    CommentListView(placeId: place.id)
                        .frame(minHeight: 200) // Display comments
                } else if selectedTab == 2 {
                    CommentChartView(viewModel: CommentChartViewModel(), placeId: place.id)
                        .frame(minHeight: 300) // Display the comment chart
                } else if selectedTab == 3 {
                    // Map View to display the location with a marker
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )), annotationItems: [place]) { place in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), tint: .red)
                    }
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle(place.name)
    }
}

#Preview {
    let place = Place()
    place.name = "Sample Place"
    place.address = "123 Main St"
    place.country = "Country"
    place.descriptionText = "A beautiful place to visit."
    place.types = "Type1, Type2, Type3" // Added sample types
    place.isFavorite = false
    
    // Mock image data for preview
    if let image = UIImage(systemName: "photo"), let imageData = image.jpegData(compressionQuality: 0.8) {
        let photoData = PhotoData()
        photoData.data = imageData
        place.imageDataList.append(photoData)
    }
    
    // Mock comments for preview
    let comment1 = Comment()
    comment1.text = "Beautiful place!"
    comment1.date = Date()
    comment1.placeId = place.id

    let comment2 = Comment()
    comment2.text = "Had a great time here."
    comment2.date = Date().addingTimeInterval(-86400) // 1 day ago
    comment2.placeId = place.id

    place.comments.append(comment1)
    place.comments.append(comment2)

    return PlaceDetail(place: place)
}
