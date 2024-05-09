//
//  DiseaseTrackerMapApp.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 4/30/24.
//

import SwiftUI
import CoreLocation

@main
struct DiseaseTrackerMapApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Coordinator())
                .onAppear {
                    CLLocationManager().requestAlwaysAuthorization()
                }
        }
    }
}
