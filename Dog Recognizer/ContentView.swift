//
//  ContentView.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 03/04/2023.
//

import SwiftUI
import CoreData

// create a bottom bar navigation view with home, camera and historic buttons
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var appState = AppState()
    
    var body: some View {
            TabView(selection: $appState.selectedTab) {
            HomeView()
                .tag(ContentViewTab.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            CameraView()
                .tag(ContentViewTab.camera)
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
            HistoricView()
                .tag(ContentViewTab.historic)
                .tabItem {
                    Label("Historic", systemImage: "clock")
                }
        }
    }
}

class AppState: ObservableObject {
    @Published var selectedTab: ContentViewTab = .camera
}

enum ContentViewTab {
    case home
    case camera
    case historic
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
