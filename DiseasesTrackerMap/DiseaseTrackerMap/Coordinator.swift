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
    
    static func markerKey(position: NMGLatLng, identifier: Int) -> ItemKey {
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



class Coordinator: NSObject, NMFMapViewOptionDelegate, NMCClusterMarkerUpdater, NMCLeafMarkerUpdater , ObservableObject {
    
    var mapType: NMFMapType = .basic
    var mapDetail: [String:Bool] = [NMF_LAYER_GROUP_BICYCLE:false,
                                    NMF_LAYER_GROUP_TRAFFIC:false,
                                    NMF_LAYER_GROUP_TRANSIT:false,
                                   NMF_LAYER_GROUP_BUILDING:false,
                                   NMF_LAYER_GROUP_MOUNTAIN:false,
                                  NMF_LAYER_GROUP_CADASTRAL:false]
    
    let view = NMFNaverMapView(frame: .infinite)
    
    @Published var markerTapped: Bool = false // 마커가 눌렸는지 여부
    @Published var tappedMarkerInfo: NMCLeafMarkerInfo? // 눌린 마커의 Info
    @Published var tappedMarkerTag: ItemData? // 눌린 마커의 Tag
    @Published var tappedMarkerKey: ItemKey? // 눌린 마커의 Key
    
    let pathOverlay = NMFPath()
    
    var cancellables = Set<AnyCancellable>()
    
    var diseasesData: [ItemKey: ItemData] = [:]
    
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
        
    var clusterer: NMCClusterer<ItemKey>?
    
    override init() {
        super.init()
        view.mapView.positionMode = .compass
        view.showLocationButton = true
        let builder = NMCComplexBuilder<ItemKey>()
        builder.minClusteringZoom = 9
        builder.maxClusteringZoom = 16
        builder.maxScreenDistance = 200
        builder.markerManager = MarkerManager()
        builder.clusterMarkerUpdater = self
        builder.leafMarkerUpdater = self
        self.clusterer = builder.build()
        
        self.makeClusterer() // 클러스터 만들기
        self.addMarkerListener()
//        self.getDiseaseData() // 클러스터링 작업도 포함된 메서드
        self.clusterer?.mapView = self.view.mapView
    }
    
    
    //MARK: USED TO MAKE MARKER FOR INFECTED PERSONS MOVEMENTS
    func setMarker(data: [UserRoute]) {
        _ = data.map { route in
            let marker = NMFMarker()
            marker.iconImage = NMF_MARKER_IMAGE_PINK
            marker.position = NMGLatLng(lat: route.latitude, lng: route.longitude)
            marker.mapView = view.mapView
            marker.iconImage = NMFOverlayImage(image: UIImage(systemName: "allergens")!)//NMFOverlayImage(name: "allergens")

            let infoWindow = NMFInfoWindow()
            let dataSource = NMFInfoWindowDefaultTextSource.data()
            dataSource.title = "\(route.identifier)"
            infoWindow.dataSource = dataSource
            infoWindow.open(with: marker)
        }
        
        
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
            ItemKey(identifier: 1, position: NMGLatLng(lat: 37.372, lng: 127.113)): ItemData(date: ".now + 1", region: "발생지역1"),
            ItemKey(identifier: 2, position: NMGLatLng(lat: 37.366, lng: 127.106)): ItemData(date: ".now + 3", region: "발생지역2"),
            ItemKey(identifier: 3, position: NMGLatLng(lat: 37.365, lng: 127.157)): ItemData(date: ".now + 4", region: "발생지역3"),
            ItemKey(identifier: 4, position: NMGLatLng(lat: 37.361, lng: 127.105)): ItemData(date: ".now + 8", region: "발생지역4"),
            ItemKey(identifier: 5, position: NMGLatLng(lat: 37.368, lng: 127.110)): ItemData(date: ".now + 11", region: "발생지역5"),
            ItemKey(identifier: 6, position: NMGLatLng(lat: 37.360, lng: 127.106)): ItemData(date: ".now + 14", region: "발생지역6"),
            ItemKey(identifier: 7, position: NMGLatLng(lat: 37.363, lng: 127.111)): ItemData(date: ".now + 29", region: "발생지역7")
        ]
        self.clusterer?.addAll(keyTagMap)
        
        //self.getDiseaseData()
        self.clusterer?.addAll(diseasesData)
        self.clusterer?.mapView = self.view.mapView
    }
    
    
    func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        let tag = info.tag as! ItemData
        let key = info.key as! ItemKey
        marker.captionText = "\(key.identifier)번 확진자"
        marker.iconImage = NMFOverlayImage(image: UIImage(systemName: "allergens")!)
        marker.iconTintColor = UIColor.red
        marker.width = 40
        marker.height = 40
        marker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
            self?.tappedMarkerInfo = info
            self?.tappedMarkerKey = key
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
                if tapped {
                    self?.pathOverlay.path = NMGLineString(points: [
                        NMGLatLng(lat: 37.57152, lng: 126.97714),
                        NMGLatLng(lat: 37.56607, lng: 126.98268),
                        NMGLatLng(lat: 37.56445, lng: 126.97707),
                        NMGLatLng(lat: 37.55855, lng: 126.97822)
                    ])
                    self?.pathOverlay.color = UIColor.red
                    self?.pathOverlay.mapView = self?.view.mapView
                } else {
                    self?.pathOverlay.mapView = nil
                }
            }
            .store(in: &cancellables)
    }
    
}


//MARK: API CALL
extension Coordinator {
    // 확진자들 좌표 + 정보 가져오기
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
                    let key = ItemKey(identifier: model.identifier, position: NMGLatLng(lat: model.latitude, lng: model.longitude))
                    let data = ItemData(date: model.date, region: model.region)
                    self?.diseasesData[key] = data
                }
                self?.makeClusterer()
            }
            .store(in: &cancellables)
    }
    
    // 확진자 동선 가져오기
    func getRoute(id: Int) {
        URLSession.shared.dataTaskPublisher(for: URL(string: "http://localhost:8080/routes/\(id)")!)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let reponse = response as? HTTPURLResponse, reponse.statusCode >= 200 && reponse.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [UserRoute].self, decoder: JSONDecoder())
            .sink { (completion) in
                print("COMPLETION:\(completion)")
            } receiveValue: { [weak self] (routesData) in
                
                // 동선 화면에 나타내기
                self?.pathOverlay.path = NMGLineString(points: routesData.map({ userRoute in
                    NMGLatLng(lat: userRoute.latitude, lng: userRoute.longitude)
                }))
                self?.pathOverlay.mapView = self?.view.mapView
                
                // 동선 마크로 만들기
                self?.setMarker(data: routesData)
                
            }
            .store(in: &cancellables)

    }
}

extension Coordinator {
    func setRouteMarker() {
        
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
