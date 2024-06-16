//
//  TasksView.swift
//  STP
//
//  Created by Eric Wong on 7/6/2024.
//

import SwiftUI
import RealmSwift

struct TasksView: View {
    @Binding var currentDate: Date
    @ObservedResults(TaskData.self, sortDescriptor: SortDescriptor(keyPath: "creationDate", ascending: true)) var tasks
    @StateObject private var exchangeRateManager = ExchangeRateManager()
    @State private var selectedCurrency = "HKD"
    @State private var showTaskChartView = false
    
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: currentDate.wrappedValue)
        let endOfDate = calendar.date(byAdding: .day, value: 1, to: startOfDate)!
        
        $tasks.filter = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", startOfDate as NSDate, endOfDate as NSDate)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 35) {
                    // Currency Conversion Button
                    HStack {
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(["HKD", "JPY"], id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedCurrency) { newCurrency in
                            exchangeRateManager.fetchExchangeRates(baseCurrency: "HKD")
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showTaskChartView.toggle()
                        }) {
                            VStack{
                                HStack{
                                    Text("Daily Total Expense: ")
                                }
                                
                                HStack {
                                    Text("\(String(format: "%.2f", dailyTotalExpense())) \(selectedCurrency)")
                                }
                            }
                            .font(.headline)
                            .padding()
                            .background(Color.taskColor1)
                            .foregroundColor(.taskColor2)
                            .cornerRadius(10)
                        }
                    }
                    .padding([.horizontal, .top], 5)
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    
                    ForEach(tasks) { task in
                        TaskRowView(task: task, exchangeRateManager: exchangeRateManager, selectedCurrency: $selectedCurrency)
                            .background(alignment: .leading) {
                                if tasks.last?.id != task.id {
                                    Rectangle()
                                        .frame(width: 2)
                                        .offset(x: 8)
                                        .padding(.bottom, -35)
                                }
                            }
                    }
                }
                .padding([.vertical, .leading], 15)
                .padding(.top, 15)
                .overlay {
                    if tasks.isEmpty {
                        Text("No Task's Found")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .frame(width: 100)
                            .offset(x: 0, y: 80)
                    }
                }
            }
            .sheet(isPresented: $showTaskChartView) {
                TaskChartView()
            }
        }
    }
    
    private func dailyTotalExpense() -> Float {
        let rate = exchangeRateManager.exchangeRates[selectedCurrency] ?? 1.0
        return tasks.reduce(0) { $0 + $1.convertedExpense(to: selectedCurrency, with: rate) }
    }
}
