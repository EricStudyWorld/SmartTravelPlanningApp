//
//  Comment.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import RealmSwift
import Foundation

class Comment: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var placeId: ObjectId
    @Persisted var text: String = ""
    @Persisted var date: Date = Date()
    @Persisted var recommends: String = ""
    @Persisted var imageDataList: List<CommentPhotoData> = List<CommentPhotoData>()
}
