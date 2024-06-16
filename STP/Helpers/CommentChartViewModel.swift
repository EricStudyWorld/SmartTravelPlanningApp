//
//  CommentChartViewModel.swift
//  STP
//
//  Created by Eric Wong on 16/6/2024.
//

import SwiftUI
import RealmSwift
import Charts

class CommentChartViewModel: ObservableObject {
    @Published var dailyComments: [DailyComment] = []
    @Published var totalComments: Int = 0

    func fetchComments(for placeId: ObjectId, month: Date) {
        do {
            let realm = try Realm()
            if let place = realm.object(ofType: Place.self, forPrimaryKey: placeId) {
                let comments = place.comments.filter("recommends == 'Try Next Time' AND date >= %@ AND date < %@", month.startOfMonth(), month.endOfMonth())
                let groupedComments = Dictionary(grouping: comments, by: { Calendar.current.dateComponents([.year, .month, .day], from: $0.date) })
                
                var dailyData: [DailyComment] = []
                for (dateComponents, comments) in groupedComments {
                    if let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day {
                        let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
                        dailyData.append(DailyComment(date: date, count: comments.count))
                    }
                }
                
                dailyComments = dailyData.sorted(by: { $0.date < $1.date })
                totalComments = comments.count
            }
        } catch {
            print("Error fetching comments: \(error.localizedDescription)")
        }
    }
}

struct DailyComment: Identifiable {
    var id = UUID()
    var date: Date
    var count: Int
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }

    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
