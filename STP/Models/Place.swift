//
//  Place.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import RealmSwift

class Place: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var address: String = ""
    @Persisted var country: String = ""
    @Persisted var descriptionText: String = ""
    @Persisted var types: String = ""
    @Persisted var isFavorite: Bool = false
    @Persisted var imageDataList: List<PhotoData> = List<PhotoData>()
    @Persisted var latitude: Double = 0.0
    @Persisted var longitude: Double = 0.0
    @Persisted var comments: List<Comment> = List<Comment>()
}
