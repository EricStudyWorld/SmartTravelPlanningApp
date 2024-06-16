//
//  NewPlaceView.swift
//  STP
//
//  Created by Eric Wong on 1/6/2024.
//

import SwiftUI
import RealmSwift

struct NewPlaceView: View {
    @Binding var isPresented: Bool
    @ObservedRealmObject var place: Place
    @State private var name: String
    @State private var address: String
    @State private var country: String
    @State private var descriptionText: String
    @State private var types: String
    @State private var isFavorite: Bool
    @State private var imageDataList: [Data] = []
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var showingImagePicker = false

    let standardImageSize: CGFloat = 300

    // List for the picker
    let countries = ["東京", "大阪"]
    let typesOf = ["拉麵", "烏冬", "燒肉", "壽司", "鰻魚飯", "串燒", "炸豬扒", "吉列牛", "牛舌", "天婦羅", "蟹", "吞拿魚", "居酒屋", "洋食", "甜品", "其他"]

    init(isPresented: Binding<Bool>, place: Place? = nil, selectedPlacemark: MTPlacemark? = nil) {
        self._isPresented = isPresented
        let place = place ?? Place()
        self._place = ObservedRealmObject(wrappedValue: place)
        self._name = State(initialValue: selectedPlacemark?.name ?? place.name)
        self._address = State(initialValue: selectedPlacemark?.address ?? place.address)
        self._country = State(initialValue: place.country)
        self._descriptionText = State(initialValue: place.descriptionText)
        self._types = State(initialValue: place.types)
        self._isFavorite = State(initialValue: place.isFavorite)
        self._imageDataList = State(initialValue: place.imageDataList.map { $0.data })
        self._latitude = State(initialValue: selectedPlacemark?.latitude ?? place.latitude)
        self._longitude = State(initialValue: selectedPlacemark?.longitude ?? place.longitude)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                    TextField("Address", text: $address)
                    
                    // Picker for Country selection
                    Picker("Country", selection: $country) {
                        ForEach(countries, id: \.self) { country in
                            Text(country).tag(country)
                        }
                    }
                    
                    TextField("Description", text: $descriptionText)
                    
                    Picker("Types", selection: $types) {
                        ForEach(typesOf, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    Toggle(isOn: $isFavorite) {
                        Text("Favorite")
                    }
                }

                Section(header: Text("Location")) {
                    TextField("Latitude", value: $latitude, format: .number)
                    TextField("Longitude", value: $longitude, format: .number)
                }

                Section(header: Text("Images")) {
                    ForEach(imageDataList, id: \.self) { imageData in
                        if let uiImage = UIImage(data: imageData) {
                            HStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: standardImageSize, height: standardImageSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        showingImagePicker.toggle()
                                    }
                                
                                // Delete button
                                Button(action: {
                                    if let index = imageDataList.firstIndex(of: imageData) {
                                        imageDataList.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    Button(action: {
                        showingImagePicker.toggle()
                    }) {
                        Text("Add Image")
                    }
                }
            }
            .navigationTitle(place.realm == nil ? "New Place" : "Edit Place")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                savePlace()
                isPresented = false
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(imageDataList: $imageDataList)
            }
        }
    }

    private func savePlace() {
        do {
            let realm = try Realm()
            try realm.write {
                if place.realm == nil {
                    // The place is unmanaged, so we need to add it to the Realm
                    let newPlace = Place()
                    newPlace.name = name
                    newPlace.address = address
                    newPlace.country = country
                    newPlace.descriptionText = descriptionText
                    newPlace.types = types // Set the types field
                    newPlace.isFavorite = isFavorite
                    newPlace.latitude = latitude
                    newPlace.longitude = longitude
                    for imageData in imageDataList {
                        let photoData = PhotoData()
                        photoData.data = imageData
                        newPlace.imageDataList.append(photoData)
                    }
                    realm.add(newPlace)
                } else {
                    // The place is managed, so we need to thaw it first
                    if let thawedPlace = place.thaw() {
                        thawedPlace.name = name
                        thawedPlace.address = address
                        thawedPlace.country = country
                        thawedPlace.descriptionText = descriptionText
                        thawedPlace.types = types // Set the types field
                        thawedPlace.isFavorite = isFavorite
                        thawedPlace.latitude = latitude
                        thawedPlace.longitude = longitude
                        thawedPlace.imageDataList.removeAll()
                        for imageData in imageDataList {
                            let photoData = PhotoData()
                            photoData.data = imageData
                            thawedPlace.imageDataList.append(photoData)
                        }
                    }
                }
            }
        } catch {
            print("Error saving place: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NewPlaceView(isPresented: .constant(true))
}
