# Virus_information_Project
<div align="center">
  <img style="width:45%; display:block; margin:0 auto;" src="https://github.com/LouiIII3/Social_media_project/assets/119919129/bdb22358-5e84-46e5-abe2-b3d89d1ae400"/>
</div>

## 프로젝트 소개
바이러스 정보를 알려주는 서비스 입니다.


### 주요 기능
|기능|설명|사용 기술|
|-----|------|---|
|지도 정보|바이러스 정보들을 띄우기 위함|Naver 지도 API|



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


