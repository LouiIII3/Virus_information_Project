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
    
    //MARK: 탭한 마커의 정보
    @Published var markerTapped: Bool = false // 마커가 눌렸는지 여부
    @Published var tappedMarkerInfo: NMCLeafMarkerInfo? // 눌린 마커의 Info
    @Published var tappedMarkerTag: ItemData? // 눌린 마커의 Tag
    @Published var tappedMarkerKey: ItemKey? // 눌린 마커의 Key
    @Published var clusteredMarkerTapped: Bool = false // 클러스터 마커가 눌렸는지 여부
    @Published var clusteredMarkerData: [ItemKey : ItemData] = [:]
//    @Published var clusteredMarkerKey: [ItemKey]?
    
    
    //MARK: 확진자 + 회복자 현황
    @Published var recovered: Int =  0
    @Published var nrecovered: Int = 0
    @Published var tcovered: Int = 0
    
    let marker = NMFMarker()
    
    
    //MARK: 동선확인을 위한 경로선
    private let pathOverlay = NMFPath()
    
    func resetPathAndMarkers() {
        //        pathOverlay.mapView = nil
        marker.mapView = nil
    }
    
    
    //MARK: COMBINE
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
        view.mapView.maxZoomLevel = 16
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
        let infoWindow = NMFInfoWindow()
        let dataSource = NMFInfoWindowDefaultTextSource.data()
        _ = data.map { route in
            print(route.identifier)
            marker.iconImage = NMF_MARKER_IMAGE_PINK
            marker.position = NMGLatLng(lat: route.latitude, lng: route.longitude)
            marker.mapView = view.mapView
            marker.iconImage = NMFOverlayImage(image: UIImage(systemName: "allergens")!)//NMFOverlayImage(name: "allergens")
            
            dataSource.title = "\(route.identifier)"
            infoWindow.dataSource = dataSource
            infoWindow.open(with: marker)
            
        }
    }

    func makeClusterer() {
        let builder = NMCComplexBuilder<ItemKey>()
        builder.minClusteringZoom = 9
        builder.maxClusteringZoom = 16
        builder.maxScreenDistance = 3
        builder.clusterMarkerUpdater = self
        builder.leafMarkerUpdater = self
        builder.markerManager = MarkerManager()
        
        self.clusterer = builder.build()
        
        let keyTagMap = [
            ItemKey(identifier: 1, position: NMGLatLng(lat: 37.372, lng: 127.113)): ItemData( date: ".now + 1", region: "발생지역1"),
            ItemKey(identifier: 2, position: NMGLatLng(lat: 37.372, lng: 127.133)): ItemData( date: ".now + 2", region: "발생지역2"),
            ItemKey(identifier: 3, position: NMGLatLng(lat: 37.372, lng: 127.413)): ItemData( date: ".now + 3", region: "발생지역3"),
            ItemKey(identifier: 4, position: NMGLatLng(lat: 37.372, lng: 127.513)): ItemData( date: ".now + 4", region: "발생지역4"),
            ItemKey(identifier: 5, position: NMGLatLng(lat: 37.372, lng: 127.673)): ItemData( date: ".now + 5", region: "발생지역5"),
            ItemKey(identifier: 6, position: NMGLatLng(lat: 37.372, lng: 127.103)): ItemData( date: ".now + 6", region: "발생지역6"),
            ItemKey(identifier: 7, position: NMGLatLng(lat: 37.372, lng: 127.903)): ItemData( date: ".now + 7", region: "발생지역7"),
            ItemKey(identifier: 8, position: NMGLatLng(lat: 37.373, lng: 127.913)): ItemData( date: ".now + 8", region: "발생지역8"),
            ItemKey(identifier: 9, position: NMGLatLng(lat: 37.373, lng: 127.9136)): ItemData( date: ".now + 9", region: "발생지역9")
        ]
        // 가짜 데이터 저장하기
//        clusteredMarkerData
        for model in keyTagMap {
            let key = ItemKey(identifier: model.key.identifier, position: NMGLatLng(lat: model.key.position.lat, lng: model.key.position.lng))
            let data = ItemData(date: model.value.date, region: model.value.region)
//            self.clusteredMarkerData[key] = data
            self.diseasesData[key] = data
        }
        
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
        
        marker.isHideCollidedMarkers = true
        
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
        marker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
            print("마커 터치")
            print("marker:\(marker.userInfo)")
            
            // 똑같은 해당 위치에 사람들의 info를 사용자한테 보여줘야한다
            if self?.view.mapView.zoomLevel ?? 0 < 15 {
                let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: info.position.lat, lng: info.position.lng), zoomTo: 13)
                cameraUpdate.animation = .easeIn
                self?.view.mapView.moveCamera(cameraUpdate)
            } else {
                // 이 위치에서 0.0006 보다 작은 것들을 모두 찾아서 탭한 클러스터에다가 넣기
                DispatchQueue.main.async {
                    print(self?.diseasesData.count)
                    self?.diseasesData.forEach { data in
                        print("추가했는데:\(data.key), \(data.value), 그리고 \(abs(data.key.position.lng - info.position.lng))")
                        
                        if abs(data.key.position.lng - info.position.lng) < 0.0006 {
                            self?.clusteredMarkerData[data.key] = data.value
                            print("추가했는데:\(data.key), \(data.value)")
                        }
                        self?.clusteredMarkerTapped = true
                    }
                    
                }
            }
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
        //        $markerTapped
        //            .receive(on: DispatchQueue.main)
        //            .sink { (completion) in
        //                print("COMPLETION: \(completion)")
        //            } receiveValue: { [weak self] (tapped) in
        //                if tapped {
        //                    self?.pathOverlay.path = NMGLineString(points: [
        //                        NMGLatLng(lat: 37.57152, lng: 126.97714),
        //                        NMGLatLng(lat: 37.56607, lng: 126.98268),
        //                        NMGLatLng(lat: 37.56445, lng: 126.97707),
        //                        NMGLatLng(lat: 37.55855, lng: 126.97822)
        //                    ])
        //                    self?.pathOverlay.color = UIColor.red
        //                    self?.pathOverlay.mapView = self?.view.mapView
        //                } else {
        //                    self?.pathOverlay.mapView = nil
        //                }
        //            }
        //            .store(in: &cancellables)
    }
    
}


//MARK: API CALL
extension Coordinator {
    // 확진자들 좌표 + 정보 가져오기
    func getDiseaseData() {
        URLSession.shared.dataTaskPublisher(for: URL(string: "http://lsproject.shop:8080/all")!)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [DiseaseModel].self, decoder: JSONDecoder())
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
    func getRoute(identifier: Int) {
        URLSession.shared.dataTaskPublisher(for: URL(string: "http://lsproject.shop:8080/routes/\(identifier)")!)
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
    
//    func getFakeMarker() {
//        let routesData: [UserRoute] = [
//            ItemKey(identifier: 1, position: NMGLatLng(lat: 37.372, lng: 127.113)): ItemData( date: ".now + 1", region: "발생지역1"),
//            ItemKey(identifier: 2, position: NMGLatLng(lat: 37.372, lng: 127.133)): ItemData( date: ".now + 2", region: "발생지역2"),
//            ItemKey(identifier: 3, position: NMGLatLng(lat: 37.372, lng: 127.413)): ItemData( date: ".now + 3", region: "발생지역3"),
//            ItemKey(identifier: 4, position: NMGLatLng(lat: 37.372, lng: 127.513)): ItemData( date: ".now + 4", region: "발생지역4"),
//            ItemKey(identifier: 5, position: NMGLatLng(lat: 37.372, lng: 127.673)): ItemData( date: ".now + 5", region: "발생지역5"),
//            ItemKey(identifier: 6, position: NMGLatLng(lat: 37.372, lng: 127.103)): ItemData( date: ".now + 6", region: "발생지역6"),
//            ItemKey(identifier: 7, position: NMGLatLng(lat: 37.372, lng: 127.903)): ItemData( date: ".now + 7", region: "발생지역7"),
//            ItemKey(identifier: 8, position: NMGLatLng(lat: 37.373, lng: 127.913)): ItemData( date: ".now + 8", region: "발생지역8"),
//            ItemKey(identifier: 9, position: NMGLatLng(lat: 37.373, lng: 127.9136)): ItemData( date: ".now + 9", region: "발생지역9")
//        ]
//        for model in routesData {
//            let key = ItemKey(identifier: model.identifier, position: NMGLatLng(lat: model.latitude, lng: model.longitude))
//            let data = ItemData(date: model.timestamp, region: model.locations)
//            self.diseasesData[key] = data
//        }
//    }
    
    func getFakeRoute() {
        let routesData: [UserRoute] = [
            UserRoute(id: 1, identifier: 101, timestamp: "2024-05-15T12:00:00Z", latitude: 37.5665, longitude: 126.9780, locations: "Seoul"),
            UserRoute(id: 2, identifier: 102, timestamp: "2024-05-15T12:05:00Z", latitude: 35.1796, longitude: 129.0756, locations: "Busan"),
            UserRoute(id: 3, identifier: 103, timestamp: "2024-05-15T12:10:00Z", latitude: 35.8686, longitude: 128.6056, locations: "Daegu"),
            UserRoute(id: 4, identifier: 104, timestamp: "2024-05-15T12:15:00Z", latitude: 37.4563, longitude: 126.7052, locations: "Incheon"),
            UserRoute(id: 5, identifier: 105, timestamp: "2024-05-15T12:20:00Z", latitude: 35.1603, longitude: 126.8514, locations: "Gwangju"),
            UserRoute(id: 6, identifier: 106, timestamp: "2024-05-15T12:25:00Z", latitude: 36.3510, longitude: 127.3850, locations: "Daejeon"),
            UserRoute(id: 7, identifier: 107, timestamp: "2024-05-15T12:30:00Z", latitude: 35.5384, longitude: 129.3114, locations: "Ulsan"),
            UserRoute(id: 8, identifier: 108, timestamp: "2024-05-15T12:35:00Z", latitude: 33.4996, longitude: 126.5312, locations: "Jeju"),
            UserRoute(id: 9, identifier: 109, timestamp: "2024-05-15T12:40:00Z", latitude: 37.2746, longitude: 127.0093, locations: "Suwon")
        ]
        
        var markers = [NMFMarker]()
        for data in routesData {
            marker.iconImage = NMF_MARKER_IMAGE_PINK
            print("좌표:\(data.latitude), \(data.longitude)")
            marker.position = NMGLatLng(lat: data.latitude, lng: data.longitude)
            marker.iconImage = NMFOverlayImage(image: UIImage(systemName: "allergens")!)//NMFOverlayImage(name: "allergens")
            marker.iconTintColor = UIColor.blue
            markers.append(marker)
        }
        
        DispatchQueue.main.async { [weak self] in
            for marker in markers {
                marker.mapView = self?.view.mapView
            }
        }
    }
    
}

extension Coordinator {
    func getSummeryInfo() {
        URLSession.shared.dataTaskPublisher(for: URL(string: "http://lsproject.shop:8080/recovered")!)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let reponse = response as? HTTPURLResponse, reponse.statusCode >= 200 && reponse.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: RecoveryModel.self, decoder: JSONDecoder())
            .sink { (completion) in
                print("COMPLETION:\(completion)")
            } receiveValue: { [weak self] recovery in
                self?.recovered = recovery.rCount
                self?.nrecovered = recovery.nrCount
                self?.tcovered = recovery.tCount
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

