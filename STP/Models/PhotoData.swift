//
//  PhotoData.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import RealmSwift
import SwiftUI

class PhotoData: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var data: Data = Data()
}
