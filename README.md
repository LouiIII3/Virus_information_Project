# Virus_information_Project
<div align="center">
  <img style="width:45%; display:block; margin:0 auto;" src="https://github.com/LouiIII3/Social_media_project/assets/119919129/bdb22358-5e84-46e5-abe2-b3d89d1ae400"/>
</div>

## 프로젝트 소개
바이러스 정보를 알려주는 서비스 입니다.


### Key Features

| **Feature**               | **Description**                                                                                      | **Technologies Used**                                                                                            |
|---------------------------|------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| Real-time Virus Information | Provides the latest virus outbreak status and infection statistics, location-based area information, and nearby hospital locations | Frontend: Swift <br>Backend: SpringBoot <br>API: RESTful API  |               |
| Data Visualization         | Visualizes virus spread through graphs and maps                                                    | Data Visualization Library: Naver Maps API                                            |
| Server Framework           | Provides quick server setup and scalability                                                        | SpringBoot                                                                                 |
| Database                   | Data storage and management                                                                        | SQL: MySQL, MariaDB<br>NoSQL: MongoDB                                                              |               
| Deployment and Maintenance | Server and database hosting, system performance monitoring, and log analysis                       | Cloud Infrastructure: AWS |


### 주요 기능
| **기능**              | **설명**                                                                                     | **사용기술**                                                                                          |
|-----------------------|----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| 실시간 바이러스 정보 제공 | 최신 바이러스 발생 현황 및 감염자 수 통계 제공, 사용자 위치 기반 지역 정보 제공, 근처 병원 위치 제공 | 프론트엔드: Swift <br>백엔드: SpringBoot <br>API: RESTful API  |               |
| 데이터 시각화         | 그래프와 지도를 통한 바이러스 확산 현황 시각화                                                   | 데이터 시각화 라이브러리: Naver Maps API                                            |
| 서버 프레임워크       | 빠른 서버 구축 및 확장성 제공                                                                   | SpringBoot                                                                          |
| 데이터베이스          | 데이터 저장 및 관리                                                                           | SQL: MySQL, MariaDB<br>NoSQL: MongoDB                                                              |               
| 배포 및 유지보수      | 서버 및 데이터베이스 호스팅, 시스템 성능 모니터링 및 로그 분석 | 클라우드 인프라: AWS|



## 2. UI 사진
### 클라이언트 (iOS)
| 메인페이지 | --- | --- |
|-------|-------|-------|
| ![main](https://github.com/LouiIII3/Virus_information_Project/assets/119919129/ee8cfdae-150b-47d6-ae84-9e1e94c5f8b5) | ![NONE](NULL) | ![NONE2](NULL) |



클라이언트용 코드 <details><summary>접기/펼치기</summary>
### adding Dependency using cocoapods
To integrate NMapsMap into your Xcode project use CocoaPods, specify it in your Podfile:
``` 
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'DiseaseTrackerMap' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DiseaseTrackerMap
  pod 'NMapsMap'

end
```

### import NMapsMap
`import NMapsMap`


### setting marker to show infected persons movements
```swift
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
```

</details>




서버 코드 <details><summary>접기/펼치기</summary>
### Database Field (Total Confirmed Cases Information)
We have information about the total confirmed cases.
``` 
@Entity
@Data
public class Virus {
    @Id
    private Long id;

    // Date
    private LocalDate date;
    // Region
    private String region;
    // Confirmed Case Number
    private int identifier;
    // Whether Recovered
    private boolean recovered;
    // Latitude
    private double latitude;
    // Longitude
    private double longitude;
}
```


</details>


