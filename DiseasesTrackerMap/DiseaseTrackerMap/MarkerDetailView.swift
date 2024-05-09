//
//  MarkerDetailView.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 5/4/24.
//

import SwiftUI

struct MarkerDetailView: View {
    
    //    @Environment(Coordinator.self) var coordinator
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        VStack {
                if let key = coordinator.tappedMarkerKey {
                    TextView(content: Text("\(key.cases)번 확진자"))
            }
            VStack {
                if let tag = coordinator.tappedMarkerTag {
                    TextView(content: Text("발생시간:\(tag.date)"))
                    TextView(content: Text("발생지역:\(tag.region)"))
                }
            }
            Spacer()
        }
        .padding()
        .onDisappear {
            coordinator.markerTapped = false
        }
        
        
        .padding()
    }
}

extension MarkerDetailView {
    func TextView(content: some View) -> some View{
        HStack {
            content
            Spacer()
        }
        .padding(3)
    }
}

struct MarkerDetailScreen: View {
    
    var body: some View {
        MarkerDetailView()
    }
}

#Preview {
    MarkerDetailView()
    //        .environment(Coordinator())
        .environmentObject(Coordinator())
}
