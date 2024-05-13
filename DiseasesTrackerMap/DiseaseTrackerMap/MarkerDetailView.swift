//
//  MarkerDetailView.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 5/4/24.
//

import SwiftUI

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(height: 55)
            .frame(maxWidth: 100)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0.0, y: 10.0)
        
    }
}


struct MarkerDetailView: View {
    
    //    @Environment(Coordinator.self) var coordinator
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if let identifier = coordinator.tappedMarkerKey?.identifier {
                        coordinator.getRoute(id: identifier)
                    }
                }, label: {
                    VStack {
                        Image(systemName: "mappin.circle")
                        Text("동선확인")
                            .foregroundStyle(.white)
                    }
                })
                .buttonStyle(PressableStyle())
                
                Spacer()
            }
            if let key = coordinator.tappedMarkerKey {
                TextView(content: Text("\(key.identifier)번 확진자"))
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
