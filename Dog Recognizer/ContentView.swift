//
//  ContentView.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 03/04/2023.
//

import SwiftUI

// create a bottom bar navigation view with home, camera and historic buttons
struct ContentView: View {
    @StateObject var appState = AppState()
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tag(ContentViewTab.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .border(Color.red)
            CameraView()
                .tag(ContentViewTab.camera)
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
                .scaledToFit()
                .border(Color.red)
            HistoricView()
                .tag(ContentViewTab.historic)
                .tabItem {
                    Label("Historic", systemImage: "clock")
                }
        }.environmentObject(appState)
    }
}

class AppState: ObservableObject {
    @Published var selectedTab: ContentViewTab = .camera
    @Published var homeNavigation: [HomeNavDestination] = []
    @Published var cameraNavigation: [CameraNavDestination] = []
    @Published var historicNavigation: [HistoricNavDestination] = []
}

enum ContentViewTab {
    case home
    case camera
    case historic
}

enum HomeNavDestination {

}

enum CameraNavDestination {
    case Camera
}

enum HistoricNavDestination {

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
