//
//  LocationDetailView.swift
//  STP
//
//  Created by Eric Wong on 5/6/2024.
//

import SwiftUI
import MapKit
import SwiftData

struct LocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var destination: Destination?
    var selectedPlacemark: MTPlacemark?
    @Binding var showRoute: Bool
    @Binding var travelInterval: TimeInterval?
    @Binding var transportType: MKDirectionsTransportType
    
    var travelTime: String? {
        guard let travelInterval else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: travelInterval)
    }
    
    @State private var name = ""
    @State private var address = ""
    @State private var showNewPlaceView = false
    @State private var lookaroundScene: MKLookAroundScene?
    
    var isChanged: Bool {
        guard let selectedPlacemark else { return false }
        return (name != selectedPlacemark.name || address != selectedPlacemark.address)
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .center) {
                    if destination != nil {
                        TextField("Name", text: $name)
                            .font(.title)
                            .multilineTextAlignment(.center)
                        TextField("Address", text: $address, axis: .vertical)
                            .multilineTextAlignment(.center)
                        if isChanged {
                            Button("Update") {
                                selectedPlacemark?.name = name
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                selectedPlacemark?.address = address
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        Text(selectedPlacemark?.name ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                        Text(selectedPlacemark?.address ?? "")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding(.trailing)
                    }
                    if destination == nil {
                        HStack {
                            Button {
                                transportType = .automobile
                            } label: {
                                Image(systemName: "car")
                                    .symbolVariant(transportType == .automobile ? .circle : .none)
                                    .imageScale(.large)
                            }
                            Button {
                                transportType = .walking
                            } label: {
                                Image(systemName: "figure.walk")
                                    .symbolVariant(transportType == .walking ? .circle : .none)
                                    .imageScale(.large)
                            }
                            if let travelTime {
                                let prefix = transportType == .automobile ? "Driving" : "Walking"
                                Text("\(prefix) time: \(travelTime)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            if let lookaroundScene {
                LookAroundPreview(initialScene: lookaroundScene)
                    .frame(height: 200)
                    .frame(width: 390)
                    .padding()
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            HStack {
                Spacer()
                if let destination {
                    let inList = (selectedPlacemark != nil && selectedPlacemark?.destination != nil)
                    Button {
                        if let selectedPlacemark {
                            if selectedPlacemark.destination == nil {
                                destination.placemarks.append(selectedPlacemark)
                            } else {
                                selectedPlacemark.destination = nil
                            }
                            dismiss()
                        }
                    } label: {
                        Label(inList ? "Remove" : "Add", systemImage: inList ? "minus.circle" : "plus.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(inList ? .red : .green)
                    .disabled((name.isEmpty || isChanged))
                } else {
                    VStack {
                        HStack{
                            Button("Open in maps", systemImage: "map") {
                                if let selectedPlacemark {
                                    let placemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
                                    let mapItem = MKMapItem(placemark: placemark)
                                    mapItem.name = selectedPlacemark.name
                                    mapItem.openInMaps()
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            Button("Show Route", systemImage: "location.north") {
                                showRoute.toggle()
                            }
                            .fixedSize(horizontal: true, vertical: false)
                        }
                        HStack {
                            Button("Add as New Place") {
                                showNewPlaceView.toggle()
                            }
                            .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(.bordered)
                }
            }
            Spacer()
        }
        .padding()
        .task(id: selectedPlacemark) {
            await fetchLookaroundPreview()
        }
        .onAppear {
            if let selectedPlacemark, destination != nil {
                name = selectedPlacemark.name
                address = selectedPlacemark.address
            }
        }
        .sheet(isPresented: $showNewPlaceView) {
            NewPlaceView(isPresented: $showNewPlaceView, selectedPlacemark: selectedPlacemark)
        }
    }
    
    func fetchLookaroundPreview() async {
        if let selectedPlacemark {
            lookaroundScene = nil
            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: selectedPlacemark.coordinate)
            lookaroundScene = try? await lookaroundRequest.scene
        }
    }
}

#Preview("Destination Tab") {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<Destination>()
    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
    let selectedPlacemark = destination.placemarks[0]
    return LocationDetailView(
        destination: destination,
        selectedPlacemark: selectedPlacemark,
        showRoute: .constant(false),
        travelInterval: .constant(nil),
        transportType: .constant(.automobile)
    )
}

#Preview("TripMap Tab") {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<MTPlacemark>()
    let placemarks = try! container.mainContext.fetch(fetchDescriptor)
    let selectedPlacemark = placemarks[0]
    return LocationDetailView(
        selectedPlacemark: selectedPlacemark,
        showRoute: .constant(false),
        travelInterval: .constant(TimeInterval(1000)),
        transportType: .constant(.automobile)
    )
}
