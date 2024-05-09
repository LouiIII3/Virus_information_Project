import UIKit
import SwiftUI
import NMapsMap
import Combine


class ItemKey: NSObject, NMCClusteringKey {
    let cases: Int
    let position: NMGLatLng // 경도 위도
    
    init(cases: Int, position: NMGLatLng) {
        self.cases = cases
        self.position = position
    }
    
    static func markerKey(position: NMGLatLng, cases: Int) -> ItemKey {
        return ItemKey(cases: cases, position: position)
    }
    
    override func isEqual(_ o: Any?) -> Bool {
        guard let o = o as? ItemKey else {
            return false
        }
        if self === o {
            return true
        }
        
        return o.cases == self.cases
    }
    
    override var hash: Int {
        return self.cases
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return ItemKey(cases: self.cases, position: self.position)
    }
}



class Coordinator: NSObject, NMFMapViewOptionDelegate, NMCClusterMarkerUpdater, NMCLeafMarkerUpdater , ObservableObject {
    
//    static let shared = Coordinator()
    
    var mapType: NMFMapType = .basic
    var mapDetail: [String:Bool] = [NMF_LAYER_GROUP_BICYCLE:false,
                                    NMF_LAYER_GROUP_TRAFFIC:false,
                                    NMF_LAYER_GROUP_TRANSIT:false,
                                   NMF_LAYER_GROUP_BUILDING:false,
                                   NMF_LAYER_GROUP_MOUNTAIN:false,
                                  NMF_LAYER_GROUP_CADASTRAL:false]
    
    let view = NMFNaverMapView(frame: .infinite)
    
    @Published var markerTapped: Bool = false
    var test: String = "테스트"
    
    @Published var tappedMarkerInfo: NMCLeafMarkerInfo?
    @Published var tappedMarkerTag: ItemData? // = .init(name: "", date: Date(), region: "", cases: 0)
    
    let arrowheadPath = NMFArrowheadPath()
    
    var cancellables = Set<AnyCancellable>()
    
    var diseasesData: [ItemKey: ItemData] = [:]
    
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
        
        self.makeClusterer() // 클러스터 만들기
//        self.getDiseaseData() // 클러스터링 작업도 포함된 메서드
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
            ItemKey(cases: 1, position: NMGLatLng(lat: 37.372, lng: 127.113)): ItemData(date: ".now + 1", region: "발생지역1"),
            ItemKey(cases: 2, position: NMGLatLng(lat: 37.366, lng: 127.106)): ItemData(date: ".now + 3", region: "발생지역2"),
            ItemKey(cases: 3, position: NMGLatLng(lat: 37.365, lng: 127.157)): ItemData(date: ".now + 4", region: "발생지역3"),
            ItemKey(cases: 4, position: NMGLatLng(lat: 37.361, lng: 127.105)): ItemData(date: ".now + 8", region: "발생지역4"),
            ItemKey(cases: 5, position: NMGLatLng(lat: 37.368, lng: 127.110)): ItemData(date: ".now + 11", region: "발생지역5"),
            ItemKey(cases: 6, position: NMGLatLng(lat: 37.360, lng: 127.106)): ItemData(date: ".now + 14", region: "발생지역6"),
            ItemKey(cases: 7, position: NMGLatLng(lat: 37.363, lng: 127.111)): ItemData(date: ".now + 29", region: "발생지역7")
        ]
        self.clusterer?.addAll(keyTagMap)
        
        //self.getDiseaseData()
        self.clusterer?.addAll(diseasesData)
        self.clusterer?.mapView = self.view.mapView
    }
    
    
    func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        let tag = info.tag as! ItemData
        let key = info.key as! ItemKey
        marker.captionText = "\(key.cases)번 확진자"
        marker.iconImage = NMF_MARKER_IMAGE_GREEN
        marker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
            self?.tappedMarkerInfo = info
            self?.tappedMarkerTag = tag
            self?.markerTapped = true
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

extension Coordinator {
    func addMarkerListener() {
        $markerTapped
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                print("COMPLETION: \(completion)")
            } receiveValue: { [weak self] (tapped) in
                if !tapped {
                    self?.arrowheadPath.points = [
                        NMGLatLng(lat: 37.568003, lng: 126.9772503),
                        NMGLatLng(lat: 37.5701573, lng: 126.9772503),
                        NMGLatLng(lat: 37.5701573, lng: 126.9793745)
                    ]
                    self?.arrowheadPath.mapView = self?.view.mapView
                }
            }

    }
}

extension Coordinator {
    func getDiseaseData() {
        let decoder = JSONDecoder()
        URLSession.shared.dataTaskPublisher(for: URL(string: "http://lsproject.shop:8080/all")!)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [DiseaseModel].self, decoder: decoder)
            .sink { (completion) in
                print("COMPLETION: \(completion)")
            } receiveValue: { [weak self] (returnedPosts) in
                // 받은 데이터를 사용하여 ItemKey와 ItemData를 생성하여 diseasesData에 추가
                print(returnedPosts)
                for model in returnedPosts {
                    let key = ItemKey(cases: model.cases, position: NMGLatLng(lat: model.latitude, lng: model.longitude))
                    let data = ItemData(date: model.date, region: model.region)
                    self?.diseasesData[key] = data
                }
                self?.makeClusterer()
            }
            .store(in: &cancellables)
        
    }
}
/*
 keyTagMap = [
     ItemKey(identifier: 1, position: NMGLatLng(lat: 37.372, lng: 127.113)): ItemData(name: "1번 확진자", date: .now + 1, region: "발생지역1", cases: 1),
     ItemKey(identifier: 2, position: NMGLatLng(lat: 37.366, lng: 127.106)): ItemData(name: "2번 확진자", date: .now + 3, region: "발생지역2", cases: 2),
     ItemKey(identifier: 3, position: NMGLatLng(lat: 37.365, lng: 127.157)): ItemData(name: "3번 확진자", date: .now + 4, region: "발생지역3", cases: 1),
     ItemKey(identifier: 4, position: NMGLatLng(lat: 37.361, lng: 127.105)): ItemData(name: "4번 확진자", date: .now + 8, region: "발생지역4", cases: 4),
     ItemKey(identifier: 5, position: NMGLatLng(lat: 37.368, lng: 127.110)): ItemData(name: "5번 확진자", date: .now + 11, region: "발생지역5", cases: 5),
     ItemKey(identifier: 6, position: NMGLatLng(lat: 37.360, lng: 127.106)): ItemData(name: "6번 확진자", date: .now + 14, region: "발생지역6", cases: 2),
     ItemKey(identifier: 7, position: NMGLatLng(lat: 37.363, lng: 127.111)): ItemData(name: "7번 확진자", date: .now + 29, region: "발생지역7", cases: 9)
 ]
 */
