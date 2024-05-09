import UIKit
import SwiftUI
import NMapsMap
import Combine


class ItemKey: NSObject, NMCClusteringKey {
    let identifier: Int
    let position: NMGLatLng // 경도 위도
    
    init(identifier: Int, position: NMGLatLng) {
        self.identifier = identifier
        self.position = position
    }
    
    static func markerKey(withIdentifier identifier: Int, position: NMGLatLng, cases: Int) -> ItemKey {
        return ItemKey(identifier: identifier, position: position)
    }
    
    override func isEqual(_ o: Any?) -> Bool {
        guard let o = o as? ItemKey else {
            return false
        }
        if self === o {
            return true
        }
        
        return o.identifier == self.identifier
    }
    
    override var hash: Int {
        return self.identifier
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return ItemKey(identifier: self.identifier, position: self.position)
    }
}

class ItemData: NSObject {
    let name: String
    let date: Date // 확진자 발생 날짜
    let region: String // 확진자 발생 지역
    let cases: Int // 확진자 수
    
    init(name: String, date: Date, region: String, cases: Int) {
        self.name = name
        self.date = date
        self.region = region
        self.cases = cases
    }
}


@Observable
class Coordinator: NSObject, NMFMapViewOptionDelegate, NMCClusterMarkerUpdater, NMCLeafMarkerUpdater { //}, ObservableObject {
    
//    static let shared = Coordinator()
    
    var mapType: NMFMapType = .basic
    var mapDetail: [String:Bool] = [NMF_LAYER_GROUP_BICYCLE:false,
                                    NMF_LAYER_GROUP_TRAFFIC:false,
                                    NMF_LAYER_GROUP_TRANSIT:false,
                                   NMF_LAYER_GROUP_BUILDING:false,
                                   NMF_LAYER_GROUP_MOUNTAIN:false,
                                  NMF_LAYER_GROUP_CADASTRAL:false]
    
    let view = NMFNaverMapView(frame: .infinite)
    
    var markerTapped: Bool = false
    var test: String = "테스트"
    
    var tappedMarkerInfo: NMCLeafMarkerInfo?
    var tappedMarkerTag: ItemData? // = .init(name: "", date: Date(), region: "", cases: 0)
    
    var cancellables = Set<AnyCancellable>()
    
    //    func markerTag() -> ItemData {
    //        return tappedMarkerInfo?.tag as! ItemData
    //    }
    //
    //    func markerKey() -> NMCClusteringKey? {
    //        if let key = tappedMarkerInfo?.key {
    //            return key
    //        } else {
    //            return nil
    //        }
    //    }
    
    
    
    
    class MarkerManager: NMCDefaultMarkerManager {
        override func createMarker() -> NMFMarker {
            let marker = super.createMarker()
            marker.subCaptionText = "흠"
            marker.subCaptionTextSize = 10
            marker.subCaptionColor = UIColor.white
            marker.subCaptionHaloColor = UIColor.clear
            return marker
        }
    }
    
    let CSV_ASSET_NAME = "seoul_toilet"
    
    var clusterer: NMCClusterer<ItemKey>?
    
    override init() {
        super.init()
        
        let builder = NMCComplexBuilder<ItemKey>()
        builder.minClusteringZoom = 9
        builder.maxClusteringZoom = 16
        builder.maxScreenDistance = 200
        builder.markerManager = MarkerManager()
        builder.clusterMarkerUpdater = self
        builder.leafMarkerUpdater = self
        self.clusterer = builder.build()
        
        self.makeClusterer()
        self.clusterer?.mapView = self.view.mapView
    }
    
    
    func setMarker(lat : Double, lng:Double, title: String) {
        let marker = NMFMarker()
        marker.iconImage = NMF_MARKER_IMAGE_PINK
        marker.position = NMGLatLng(lat: lat, lng: lng)
        marker.mapView = view.mapView
        
        let infoWindow = NMFInfoWindow()
        let dataSource = NMFInfoWindowDefaultTextSource.data()
        dataSource.title = "\(lat.description), \(lng.description)"
        infoWindow.dataSource = dataSource
        infoWindow.open(with: marker)
    }
    
    func makeClusterer() {
        
        let builder = NMCComplexBuilder<ItemKey>()
        builder.minClusteringZoom = 9
        builder.maxClusteringZoom = 16
        builder.maxScreenDistance = 200
        builder.clusterMarkerUpdater = self
        builder.leafMarkerUpdater = self
        builder.markerManager = MarkerManager()
        
        self.clusterer = builder.build()
        
        var keyTagMap = [ItemKey: ItemData]()
        keyTagMap = [
            ItemKey(identifier: 1, position: NMGLatLng(lat: 37.372, lng: 127.113)): ItemData(name: "1번 확진자", date: .now + 1, region: "발생지역1", cases: 1),
            ItemKey(identifier: 2, position: NMGLatLng(lat: 37.366, lng: 127.106)): ItemData(name: "2번 확진자", date: .now + 3, region: "발생지역2", cases: 2),
            ItemKey(identifier: 3, position: NMGLatLng(lat: 37.365, lng: 127.157)): ItemData(name: "3번 확진자", date: .now + 4, region: "발생지역3", cases: 1),
            ItemKey(identifier: 4, position: NMGLatLng(lat: 37.361, lng: 127.105)): ItemData(name: "4번 확진자", date: .now + 8, region: "발생지역4", cases: 4),
            ItemKey(identifier: 5, position: NMGLatLng(lat: 37.368, lng: 127.110)): ItemData(name: "5번 확진자", date: .now + 11, region: "발생지역5", cases: 5),
            ItemKey(identifier: 6, position: NMGLatLng(lat: 37.360, lng: 127.106)): ItemData(name: "6번 확진자", date: .now + 14, region: "발생지역6", cases: 2),
            ItemKey(identifier: 7, position: NMGLatLng(lat: 37.363, lng: 127.111)): ItemData(name: "7번 확진자", date: .now + 29, region: "발생지역7", cases: 9)
        ]
        self.clusterer?.addAll(keyTagMap)
        self.clusterer?.mapView = self.view.mapView
    }
    
    
    func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        let tag = info.tag as! ItemData
        marker.captionText = tag.name
        marker.iconImage = NMF_MARKER_IMAGE_GREEN
        marker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
            self?.tappedMarkerInfo = info
            self?.tappedMarkerTag = tag
            self?.markerTapped.toggle()
            return true
        }
    }
    
    
    func updateClusterMarker(_ info: NMCClusterMarkerInfo, _ marker: NMFMarker) {
        marker.captionText = "클러스터링에 포함된 데이터 수:" + String(info.size)
        marker.captionTextSize = 16
        marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
            print("마커 터치")
            print("marker:\(marker.userInfo)")
            return true // 이벤트 소비, -mapView:didTapMap:point 이벤트는 발생하지 않음
        }
        
        if info.size < 3 && info.size > 1 {
            marker.iconImage = NMF_MARKER_IMAGE_CLUSTER_LOW_DENSITY
        } else if info.size < 10 {
            marker.iconImage = NMF_MARKER_IMAGE_CLUSTER_MEDIUM_DENSITY
        } else {
            marker.iconImage = NMF_MARKER_IMAGE_CLUSTER_HIGH_DENSITY
        }
    }
    
    
    
}