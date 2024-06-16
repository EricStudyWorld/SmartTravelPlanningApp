//  PlaceList.swift
//  STP
//
//  Created by Eric Wong on 1/6/2024.
//

//  PlaceList.swift
//  STP
//
//  Created by Eric Wong on 1/6/2024.
//

import SwiftUI
import RealmSwift

struct PlaceList: View {
    @ObservedResults(Place.self) var places
    @State private var searchFilter = ""
    @State private var showFavoritesOnly = false
    @State private var filterTryNextTime = false
    @State private var createNewPlace = false
    @State private var selectedCountry = "All"
    @State private var showAlert = false
    @State private var alertMessage = ""

    @Binding var selectPlace: Place? // Binding to pass selected place back

    let countries = ["All", "東京", "大阪"]

    var filteredPlaces: [Place] {
        var predicates: [NSPredicate] = []

        if showFavoritesOnly {
            predicates.append(NSPredicate(format: "isFavorite == true"))
        }

        if !searchFilter.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[c] %@", searchFilter))
        }

        if selectedCountry != "All" {
            predicates.append(NSPredicate(format: "country == %@", selectedCountry))
        }

        let filteredResults: Results<Place>
        if predicates.isEmpty {
            filteredResults = places
        } else {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            filteredResults = places.filter(compoundPredicate)
        }

        if filterTryNextTime {
            let recommendedResults = filteredResults.filter { place in
                place.comments.contains { $0.recommends != "No" }
            }
            let sortedResults = recommendedResults.sorted(by: { (place1, place2) -> Bool in
                let tryNextTimeCount1 = place1.comments.filter("recommends == %@", "Try Next Time").count
                let tryNextTimeCount2 = place2.comments.filter("recommends == %@", "Try Next Time").count
                return tryNextTimeCount1 > tryNextTimeCount2
            })
            return Array(sortedResults)
        } else {
            return Array(filteredResults)
        }
    }

    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    ForEach(countries, id: \.self) { country in
                        Button(action: {
                            selectedCountry = country
                            checkForNoPlaces()
                        }) {
                            Text(country)
                                .padding(8) // Reduced padding
                                .background(selectedCountry == country ? Color.taskColor2 : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                }
                .padding(.horizontal, 10) // Reduced horizontal padding
                .padding(.vertical, 5) // Reduced vertical padding

                HStack {
                    List {
                        Toggle(isOn: $showFavoritesOnly) {
                            Text("Favorites only")
                        }
                        
                        Toggle(isOn: $filterTryNextTime) {
                            Text("Recommend")
                        }
                        
                        ForEach(filteredPlaces) { place in
                            Button(action: {
                                selectPlace = place
                            }) {
                                PlaceRow(place: place)
                            }
                        }
                    }
                    .animation(.default, value: filteredPlaces)
                    .listStyle(.plain)
                    .searchable(text: $searchFilter)
                    .navigationTitle("Places")
                    .overlay(alignment: .bottomTrailing) {
                        Button(action: {
                            createNewPlace.toggle()
                        }) {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                                .foregroundStyle(.taskColor2)
                                .frame(width: 55, height: 55)
                                .background(.black.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
                        }
                        .padding(15)
                    }
                }
            }
        } detail: {
            Text("Select a Place")
        }
        .sheet(isPresented: $createNewPlace) {
            NewPlaceView(isPresented: $createNewPlace)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("No Place found"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func checkForNoPlaces() {
        if filteredPlaces.isEmpty {
            if selectedCountry != "All" && places.filter("country == %@", selectedCountry).isEmpty {
                alertMessage = "No Place found in \(selectedCountry)"
            } else {
                alertMessage = "No Place found for the selected criteria"
            }
            showAlert = true
        }
    }
}

#Preview {
    PlaceList(selectPlace: .constant(nil))
}
