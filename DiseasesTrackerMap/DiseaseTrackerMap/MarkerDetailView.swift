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
                Text("확진자 이름:\(tag.name)")
                Text("위험등급:\(tag.cases)")
                Text("양성판정:\(tag.date)")
                Text("발생지역:\(tag.region)")
            }
        }
    }
}

#Preview {
    MarkerDetailView()
        .environment(Coordinator())
}
