//
//  MapSectionView.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 5/1/24.
//

import SwiftUI
import NMapsMap


enum layerGroup: String {
    case bike = "NMF_LAYER_GROUP_BICYCLE"
    case traffic = "NMF_LAYER_GROUP_TRAFFIC"
    case transportation = "NMF_LAYER_GROUP_TRANSIT"
    case building = "NMF_LAYER_GROUP_BUILDING"
    case mountain = "NMF_LAYER_GROUP_MOUNTAIN"
    case cadastral = "NMF_LAYER_GROUP_CADASTRAL"
}

struct MapSectionView: View {
//    @Environment(Coordinator.self) var map
    @EnvironmentObject var map: Coordinator

    var body: some View {
        
        VStack {
            HStack {
                mapTypeButton(mapType: .basic, imageName: "map.fill",title: "기본")
                
                mapTypeButton(mapType: .terrain, imageName: "mountain.2.fill", title: "지형도")
                
                mapTypeButton(mapType: .navi, imageName: "car.side", title: "네비게이션")

                mapTypeButton(mapType: .satellite, imageName: "airplane", title: "위성지도")
            }
            
            Divider()
            
            
            HStack {
                mapDetailButton(map: NMF_LAYER_GROUP_BICYCLE, imageName: "bicycle", title: "자전거도로")
                
                mapDetailButton(map: NMF_LAYER_GROUP_TRAFFIC, imageName: "car.2", title: "교통정보")

                mapDetailButton(map: NMF_LAYER_GROUP_TRANSIT, imageName: "tram", title: "대중교통")

                mapDetailButton(map: NMF_LAYER_GROUP_BUILDING, imageName: "building.2", title: "건물")
            }
            
            HStack {
                mapDetailButton(map: NMF_LAYER_GROUP_MOUNTAIN, imageName: "figure.walk", title: "등산로")
                
                mapDetailButton(map: NMF_LAYER_GROUP_CADASTRAL, imageName: "square.grid.2x2.fill", title: "지적편집도")
                
                
            }
        }
        .padding()
    }
    

}

extension MapSectionView {
    
    private func mapButton(action: @escaping () -> Void, imageName: String, title: String) -> some View {
        VStack {
            Button(action: action) {
                Image(systemName: imageName)
                    .foregroundStyle(Color.white)
            }
            .frame(width: 60, height: 60)
            .background(Color.secondary)
            .clipShape(Circle())
            .padding(.horizontal, 10)
            
            Text(title)
        }
    }
    
    private func mapTypeButton(mapType: NMFMapType, imageName: String, title: String) -> some View {
        mapButton(action: {
            map.mapType = mapType
        }, imageName: imageName, title: title)
    }
    
    private func mapDetailButton(map: String, imageName: String, title: String) -> some View {
        mapButton(action: {
            self.map.mapDetail[map]?.toggle()
            self.map.view.mapView.setLayerGroup(map, isEnabled: self.map.mapDetail[map]!)
        }, imageName: imageName, title: title)
    }
}





#Preview {
    MapSectionView()
//        .environment(Coordinator())
        .environmentObject(Coordinator())

}
