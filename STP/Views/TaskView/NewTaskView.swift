//
//  NewTaskView.swift
//  STP
//
//  Created by Eric Wong on 7/6/2024.
//

import SwiftUI
import RealmSwift

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    var taskToEdit: TaskData?
    
    @State private var taskTitle: String
    @State private var taskDate: Date
    @State private var taskColor: String
    @State private var taskExpense: String
    @State private var selectedPlace: Place?
    @State private var showPlaceList = false
    @State private var selectedCurrency = "HKD"
    @StateObject private var exchangeRateManager = ExchangeRateManager()
    
    @State private var originalExpense: Float = 0.0 // State to store the original expense value

    init(taskToEdit: TaskData? = nil) {
        self.taskToEdit = taskToEdit
        _taskTitle = State(initialValue: taskToEdit?.taskTitle ?? "")
        _taskDate = State(initialValue: taskToEdit?.creationDate ?? Date())
        _taskColor = State(initialValue: taskToEdit?.tint ?? "TaskColor 1")
        _taskExpense = State(initialValue: taskToEdit?.taskExpense.description ?? "0.0")
        _selectedPlace = State(initialValue: taskToEdit?.selectedPlace)
        _originalExpense = State(initialValue: taskToEdit?.taskExpense ?? 0.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .tint(.red)
            }
            .hSpacing(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Title")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Go for a Walk!", text: $taskTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
            }
            .padding(.top, 5)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Date")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    DatePicker("", selection: $taskDate)
                        .datePickerStyle(.compact)
                        .scaleEffect(0.9, anchor: .leading)
                }
                .padding(.trailing, -10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Color")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    let colors: [String] = (1...2).compactMap { index -> String in
                        return "TaskColor \(index)"
                    }
                    
                    HStack(spacing: 0) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(color))
                                .frame(width: 20, height: 20)
                                .background {
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .opacity(taskColor == color ? 1 : 0)
                                }
                                .hSpacing(.center)
                                .contentShape(.rect)
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        taskColor = color
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Expense")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                HStack {
                    TextField("0.0", text: $taskExpense)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .background(.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                        .onChange(of: taskExpense) { newValue in
                            if let newExpense = Float(newValue) {
                                originalExpense = newExpense
                            }
                        }
                    
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(["HKD", "JPY"], id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedCurrency) { newCurrency in
                        exchangeRateManager.fetchExchangeRates(baseCurrency: "HKD")
                        convertExpense(to: newCurrency)
                    }
                }
            }
            .padding(.top, 5)
            
            Button(action: {
                showPlaceList.toggle()
            }) {
                HStack {
                    if let place = selectedPlace {
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
                        Text(place.name)
                            .fontWeight(.semibold)
                    } else {
                        Text("Select Place")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
            }
            
            Spacer(minLength: 0)
            
            Button(action: {
                do {
                    let realm = try Realm()
                    try realm.write {
                        if let taskToEdit = taskToEdit?.thaw() {
                            taskToEdit.taskTitle = taskTitle
                            taskToEdit.creationDate = taskDate
                            taskToEdit.tint = taskColor
                            // Save the expense in HKD regardless of the selected currency
                            taskToEdit.taskExpense = selectedCurrency == "HKD" ? originalExpense : convertToHKD(from: originalExpense, currency: selectedCurrency)
                            taskToEdit.selectedPlace = selectedPlace != nil ? realm.create(Place.self, value: selectedPlace!, update: .modified) : nil
                        } else {
                            let task = TaskData(taskTitle: taskTitle, creationDate: taskDate, tint: taskColor, selectedPlace: selectedPlace != nil ? realm.create(Place.self, value: selectedPlace!, update: .modified) : nil)
                            // Save the expense in HKD regardless of the selected currency
                            task.taskExpense = selectedCurrency == "HKD" ? originalExpense : convertToHKD(from: originalExpense, currency: selectedCurrency)
                            realm.add(task)
                        }
                    }
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }) {
                Text(taskToEdit == nil ? "Create Task" : "Update Task")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color(taskColor), in: .rect(cornerRadius: 10))
            }
            .disabled(taskTitle.isEmpty)
            .opacity(taskTitle.isEmpty ? 0.5 : 1)
        }
        .padding(15)
        .onChange(of: selectedPlace) { _ in
            showPlaceList = false
        }
        .sheet(isPresented: $showPlaceList) {
            PlaceList(selectPlace: $selectedPlace)
        }
        .onAppear {
            exchangeRateManager.fetchExchangeRates(baseCurrency: "HKD")
        }
    }
    
    private func convertExpense(to newCurrency: String) {
        guard let rate = exchangeRateManager.exchangeRates[newCurrency] else {
            return
        }
        
        let convertedExpense = originalExpense * Float(rate)
        taskExpense = String(format: "%.2f", convertedExpense)
    }
    
    private func convertToHKD(from amount: Float, currency: String) -> Float {
        guard let rate = exchangeRateManager.exchangeRates[currency] else {
            return amount
        }
        return amount / Float(rate)
    }
}

#Preview {
    NewTaskView()
        .vSpacing(.bottom)
}
