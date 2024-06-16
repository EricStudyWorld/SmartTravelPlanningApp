//
//  TaskChartView.swift
//  STP
//
//  Created by Eric Wong on 8/6/2024.
//

import SwiftUI
import Charts
import RealmSwift

struct TaskChartView: View {
    @ObservedResults(TaskData.self, sortDescriptor: SortDescriptor(keyPath: "creationDate", ascending: true)) var tasks
    @State private var selectedMonth: Date = Date()
    @State private var selectedCurrency = "HKD"
    @StateObject private var exchangeRateManager = ExchangeRateManager()
    
    var body: some View {
        VStack {
            
            // Month Navigation
            HStack {
                Button(action: {
                    withAnimation {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    }
                }) {
                    Text("Previous Month")
                }
                
                Spacer()
                
                Text(selectedMonth, format: .dateTime.month().year())
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    }
                }) {
                    Text("Next Month")
                }
            }
            .padding()
            .background(Color.taskColor1)
            
            // Total Expense
            Text("Total Expense: \(String(format: "$%.2f", totalExpense()))")
                .font(.headline)
                .padding()
            
            Picker("Currency", selection: $selectedCurrency) {
                ForEach(["HKD", "JPY"], id: \.self) { currency in
                    Text(currency).tag(currency)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedCurrency) { newCurrency in
                exchangeRateManager.fetchExchangeRates(baseCurrency: "HKD")
            }
            .padding(.horizontal)

            Chart {
                ForEach(groupedTasksByDay(), id: \.key) { day, tasks in
                    ForEach(tasks) { task in
                        PointMark(
                            x: .value("Day", day, unit: .day),
                            y: .value("Expense", convertedExpense(task.taskExpense))
                        )
                        .foregroundStyle(by: .value("Task", task.taskTitle))
                        .symbol(by: .value("Task", task.taskTitle))
                        .symbolSize(50)
                        .annotation(position: .top) {
                            VStack {
                                Text(task.taskTitle)
                                    .font(.caption)
                                    .foregroundStyle(.black)
                                Text(String(format: "$%.2f", convertedExpense(task.taskExpense)))
                                    .font(.caption)
                                    .foregroundStyle(.black)
                            }
                            .padding(5)
                            .background(Color.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 5))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: groupedTasksByDay().map { $0.key }) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let dateValue = value.as(Date.self) {
                            Text("\(Calendar.current.component(.day, from: dateValue))")
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .padding()
        }
        .onAppear {
            exchangeRateManager.fetchExchangeRates(baseCurrency: "HKD")
        }
    }
    
    private func groupedTasksByDay() -> [(key: Date, value: [TaskData])] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let filteredTasks = tasks.filter { task in
            task.creationDate >= startOfMonth && task.creationDate <= endOfMonth
        }
        
        let grouped = Dictionary(grouping: filteredTasks) { task in
            calendar.startOfDay(for: task.creationDate)
        }
        return grouped.sorted { $0.key < $1.key }
    }
    
    private func totalExpense() -> Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let filteredTasks = tasks.filter { task in
            task.creationDate >= startOfMonth && task.creationDate <= endOfMonth
        }
        
        return filteredTasks.reduce(0) { $0 + convertedExpense($1.taskExpense) }
    }
    
    private func convertedExpense(_ expense: Float) -> Double {
        let rate = exchangeRateManager.exchangeRates[selectedCurrency] ?? 1.0
        return Double(expense) * rate
    }
}

#Preview {
    TaskChartView()
}
