//
//  MarkerDetailView.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 5/4/24.
//

import SwiftUI

struct MarkerDetailView: View {
    
    @Environment(Coordinator.self) var coordinator

    var body: some View {
        VStack {
            if let tag = coordinator.tappedMarkerTag {
                Text("발생시간:\(tag.date)")
//                Text("위험등급:\(tag.region)")
//                Text("양성판정:\(tag)")
                Text("발생지역:\(tag.region)")
            }
        }
        .padding()
    }
}

#Preview {
    MarkerDetailView()
        .environment(Coordinator())
}
