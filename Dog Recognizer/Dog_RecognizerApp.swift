//
//  Dog_RecognizerApp.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 03/04/2023.
//

import SwiftUI
import CoreData

@main
struct Dog_RecognizerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
