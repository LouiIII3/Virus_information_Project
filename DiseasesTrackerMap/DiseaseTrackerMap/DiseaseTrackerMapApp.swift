//
//  DiseaseTrackerMapApp.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 4/30/24.
//

import SwiftUI

@main
struct DiseaseTrackerMapApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environment(Coordinator())
                .environmentObject(Coordinator())
        }
    }
}
