//
//  TaskRowView.swift
//  STP
//
//  Created by Eric Wong on 7/6/2024.
//

import SwiftUI
import RealmSwift

struct TaskRowView: View {
    @ObservedRealmObject var task: TaskData
    @State private var isEditing = false
    @State private var showPlaceDetail = false
    @ObservedObject var exchangeRateManager: ExchangeRateManager
    @Binding var selectedCurrency: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: .circle)
                .overlay {
                    Circle()
                        .foregroundStyle(.clear)
                        .contentShape(.circle)
                        .frame(width: 50, height: 50)
                        .blendMode(.destinationOver)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                do {
                                    let realm = try Realm()
                                    guard let liveTask = realm.object(ofType: TaskData.self, forPrimaryKey: task.id)?.thaw() else { return }
                                    try realm.write {
                                        liveTask.isCompleted.toggle()
                                    }
                                } catch {
                                    print("Error toggling task completion: \(error.localizedDescription)")
                                }
                            }
                        }
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(task.taskTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                
                Label(task.creationDate.format("hh:mm a"), systemImage: "clock")
                    .font(.caption2)
                    .foregroundStyle(.black)
                
                if let place = task.selectedPlace {
                    HStack {
                        if let firstImageData = place.imageDataList.first?.data, let uiImage = UIImage(data: firstImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        }
                        VStack {
                            Text(place.name)
                                .font(.headline)
                                .foregroundStyle(.black)
                            
                            HStack {
                                Text(place.address)
                                    .font(.caption2)
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                    .onTapGesture {
                        showPlaceDetail.toggle()
                    }
                }
                
                HStack {
                    let rate = exchangeRateManager.exchangeRates[selectedCurrency] ?? 1.0
                    Label(String(format: "%.2f %@", task.convertedExpense(to: selectedCurrency, with: rate), selectedCurrency), systemImage: "cart.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.black)
                }
            }
            .padding(15)
            .hSpacing(.leading)
            .background(task.tintColor, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .strikethrough(task.isCompleted, pattern: .solid, color: .black)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 15 ))
            .contextMenu {
                Button("Edit Task") {
                    isEditing = true
                }
                
                Button("Delete Task", role: .destructive) {
                    do {
                        let realm = try Realm()
                        guard let liveTask = realm.object(ofType: TaskData.self, forPrimaryKey: task.id)?.thaw() else { return }
                        try realm.write {
                            realm.delete(liveTask)
                        }
                    } catch {
                        print("Error deleting task: \(error.localizedDescription)")
                    }
                }
            }
            .offset(y: -8)
            .sheet(isPresented: $isEditing) {
                NewTaskView(taskToEdit: task)
            }
            .sheet(isPresented: $showPlaceDetail) {
                if let place = task.selectedPlace {
                    PlaceDetail(place: place)
                }
            }
        }
    }
    
    var indicatorColor: Color {
        if task.isCompleted {
            return .green
        }
        
        return task.creationDate.isSameHour ? .black : (task.creationDate.isPast ? .red : .gray)
    }
}

#Preview {
    let task = TaskData(taskTitle: "Sample Task", creationDate: Date(), tint: "TaskColor 1")
    task.selectedPlace = {
        let place = Place()
        place.name = "Sample Place"
        place.address = "123 Main St"
        place.country = "Country"
        place.descriptionText = "A beautiful place to visit."
        place.types = "Type"
        place.isFavorite = false
        
        if let image = UIImage(systemName: "photo"), let imageData = image.jpegData(compressionQuality: 0.8) {
            let photoData = PhotoData()
            photoData.data = imageData
            place.imageDataList.append(photoData)
        }
        return place
    }()
    
    return TaskRowView(task: task, exchangeRateManager: ExchangeRateManager(), selectedCurrency: .constant("HKD"))
}
