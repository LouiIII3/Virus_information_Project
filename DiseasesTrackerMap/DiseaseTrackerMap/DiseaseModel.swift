//
//  DiseaseModel.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 5/2/24.
//

import Foundation
import NMapsMap


enum CodingKeys: CodingKey {
    case longitude // 경도
    case latitude // 위도
    case cases // 확진자 수
//    case confirmationDate // 확진 일자 및 시간
//    case recoveries // 완치자 수
//    case recoveryDate //
}

struct DiseaseModel: Codable {
    let longitude: Double// = NMGLatLng(lat: 36.5670135, lng: 125.9783740)
    let latitude: Double
    let cases: Int
    
    init(longitude: Double, latitude: Double, cases: Int) {
        self.longitude = longitude
        self.latitude = latitude
        self.cases = cases
    }
}
/*
 확진자 정보:
 지역 (도시, 주, 국가 등)
 확진자 수
 확진 일자 및 시간

 완치자 정보:
 완치자 수
 완치 일자 및 시간

 사망자 정보:
 사망자 수
 사망 일자 및 시간

 테스트 정보:
 총 테스트 수
 양성 테스트 수
 음성 테스트 수
 테스트 일자 및 시간

 백신 정보:
 총 접종 횟수
 접종 완료 횟수
 백신 종류
 백신 접종 일자 및 시간

 격리 및 격리 해제 정보:
 격리 중인 사람 수
 격리 해제된 사람 수
 격리 기간 정보

 병원 및 의료 시설 정보:
 병원 이름
 위치 (주소, 위도, 경도 등)
 침대 수
 의료용품 재고량(약국)

 정부 조치 및 권고 사항:
 거리두기 단계
 마스크 착용 의무화 여부
 외출 제한 및 통제 조치

 확진자 동선:
 확진자 동선 좌표
 */





// 데이터의 키를 의미하는 클래스
