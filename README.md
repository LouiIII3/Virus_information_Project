# Virus_information_Project
 Virus Information Project aims to provide comprehensive data on viruses, aiding in public awareness and informed decision-making regarding health. Its goal is to educate and empower individuals with up-to-date information on virus characteristics, transmission, symptoms, prevention, and treatment options.

<div align="center">
  <img style="width:20%; display:block; margin:0 auto;" src="https://github.com/LouiIII3/Virus_information_Project/assets/119919129/ee8cfdae-150b-47d6-ae84-9e1e94c5f8b5"/>
</div>

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
