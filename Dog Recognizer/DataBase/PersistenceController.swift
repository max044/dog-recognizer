//
//  PersistenceController.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 09/05/2023.
//

import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "HistoricDBModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Error loading Core Data store: \(error.localizedDescription)")
            }
        }
    }
}
