//
//  ContentView.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 4/30/24.
//

import SwiftUI
import NMapsMap



struct ContentView: View {
//    @Environment(Coordinator.self) var coordinator
    @EnvironmentObject var coordinator: Coordinator
    
    @State private var sectionPressed: Bool = false
    
    var body: some View {
        @Bindable var coordinators = coordinator
        NaverMapView()
            .overlay {
                methodButton
            }
            .sheet(isPresented: $sectionPressed, content: {
                MapSectionView()
                    .presentationDetents([.medium])
            })
            .sheet(isPresented: $coordinators.markerTapped, content: {
                MarkerDetailView()
            })
            .ignoresSafeArea()

    }
}



extension ContentView {
    var methodButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    sectionPressed.toggle()
                }, label: {
                    Image(systemName: "square.3.layers.3d")
                        .foregroundStyle(.black)
                    
                })
                .frame(width: 30, height: 30)
                .background(.white)
                .clipShape(Circle())
                .shadow(radius: 10)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 100)
    }
}

struct NaverMapView: UIViewRepresentable {
    @Environment(Coordinator.self) var coordinator
    
    func makeCoordinator() -> Coordinator {
        return coordinator
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        return coordinator.view
    }
    
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        uiView.mapView.mapType = coordinator.mapType
    }
    
    
}

#Preview {
    ContentView()
        .environment(Coordinator())
}
