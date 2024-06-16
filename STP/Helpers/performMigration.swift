//  performMigration.swift
//  STP
//
//  Created by Eric Wong on 7/6/2024.
//

import Foundation
import RealmSwift

func performMigration() {
    let config = Realm.Configuration(
        // Increase version number
        schemaVersion: 1, // Incremented schema version to 4
        migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: Place.className()) { oldObject, newObject in
                    // Set default value for new properties if needed
                    newObject?["name"] = oldObject?["name"] ?? ""
                    newObject?["address"] = oldObject?["address"] ?? ""
                    newObject?["country"] = oldObject?["country"] ?? ""
                    newObject?["descriptionText"] = oldObject?["descriptionText"] ?? ""
                    newObject?["types"] = oldObject?["types"] ?? ""
                    newObject?["isFavorite"] = oldObject?["isFavorite"] ?? false
                    newObject?["latitude"] = oldObject?["latitude"] ?? 0.0
                    newObject?["longitude"] = oldObject?["longitude"] ?? 0.0
                }
            }
            if oldSchemaVersion < 2 {
                // If the old schema version is less than 2, handle the migration from imageString to imageData
                migration.enumerateObjects(ofType: Place.className()) { oldObject, newObject in
                    // Convert imageString to imageData if needed
                    if let imageString = oldObject?["imageString"] as? String, let imageUrl = URL(string: imageString) {
                        do {
                            let imageData = try Data(contentsOf: imageUrl)
                            newObject?["imageData"] = imageData
                        } catch {
                            print("Error converting imageString to imageData: \(error.localizedDescription)")
                            newObject?["imageData"] = Data() // Set default value for imageData
                        }
                    } else {
                        newObject?["imageData"] = Data() // Set default value for imageData
                    }
                }
            }
            if oldSchemaVersion < 3 {
                // If the old schema version is less than 3, handle the migration from imageData to imageDataList
                migration.enumerateObjects(ofType: Place.className()) { oldObject, newObject in
                    if let imageData = oldObject?["imageData"] as? Data {
                        // Create a new PhotoData object and add it to the imageDataList
                        let photoData = migration.create(PhotoData.className(), value: ["data": imageData])
                        if var imageDataList = newObject?["imageDataList"] as? List<DynamicObject> {
                            imageDataList.append(photoData)
                        } else {
                            // Initialize imageDataList and add the photoData
                            let imageDataList = List<DynamicObject>()
                            imageDataList.append(photoData)
                            newObject?["imageDataList"] = imageDataList
                        }
                    }
                }
            }
            if oldSchemaVersion < 4 {
                // If the old schema version is less than 4, handle the addition of the comments field
                migration.enumerateObjects(ofType: Place.className()) { oldObject, newObject in
                    // Initialize comments list
                    newObject?["comments"] = List<Comment>()
                }
            }
        })

    Realm.Configuration.defaultConfiguration = config

    // Now Realm will automatically perform the migration
    do {
        _ = try Realm()
    } catch {
        print("Error performing migration: \(error.localizedDescription)")
    }
}
