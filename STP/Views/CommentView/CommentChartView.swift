//
//  CommentChartView.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import SwiftUI
import Charts
import RealmSwift

struct CommentChartView: View {
    @ObservedObject var viewModel: CommentChartViewModel
    var placeId: ObjectId
    @State private var selectedMonth: Date = Date()

    var body: some View {
        VStack {
            Text("Recommends")
                .font(.title)
                .padding()
            
            HStack {
                Button(action: {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)!
                    viewModel.fetchComments(for: placeId, month: selectedMonth)
                }) {
                    Image(systemName: "chevron.left")
                }
                Text(selectedMonth, style: .date)
                    .font(.headline)
                Button(action: {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)!
                    viewModel.fetchComments(for: placeId, month: selectedMonth)
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            Text("Total Recommends for \(selectedMonth, formatter: monthFormatter): \(viewModel.totalComments)")
                .font(.subheadline)
                .padding()
            
            Chart(viewModel.dailyComments) { data in
                BarMark(
                    x: .value("Day", data.date, unit: .day),
                    y: .value("Comments", data.count)
                )
                .foregroundStyle(by: .value("Day", data.date))
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchComments(for: placeId, month: selectedMonth)
        }
    }
}

private let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()

#Preview {
    CommentChartView(viewModel: CommentChartViewModel(), placeId: ObjectId.generate())
}
