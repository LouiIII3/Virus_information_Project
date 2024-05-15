//
//  ClusteredListView.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 5/15/24.
//

import SwiftUI

struct ClusteredListView: View {
    
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        let dataArray = Array(coordinator.clusteredMarkerData.keys)
        List(dataArray, id: \.self) { key in
            if let data = coordinator.clusteredMarkerData[key] {
                HStack {
                    Text("ID: \(key.identifier)")
                    Text("Date: \(data.date)")
                    Text("Region: \(data.region)")
                }
            }
        }
        .onAppear {
            print(coordinator.clusteredMarkerData.description)
        }
    }
}

#Preview {
    ClusteredListView()
        .environmentObject(Coordinator())
}
