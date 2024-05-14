//
//  SummeryView.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 5/14/24.
//

import SwiftUI
import Combine

struct SummeryView: View {
    
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 40)
                .foregroundStyle(Color.gray)

            HStack {
                Text("전체현황: \(coordinator.tcovered)")
                    .foregroundStyle(.white)
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 10)
//                            .opacity(0.1)
//                            .frame(width: 90, height: 30)
//                    }
//                    .padding(3)
                Text("회복자수:\(coordinator.recovered)")
                    .foregroundStyle(.white)
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 10)
//                            .opacity(0.1)
//                            .frame(width: 90, height: 30)
//                    }
//                    .padding(3)
                Text("확진자 현황:\(coordinator.nrecovered)")
                    .foregroundStyle(.white)
//                    .overlay {
//                        RoundedRectangle(cornerRadius: 10)
//                            .opacity(0.1)
//                            .frame(width: 90, height: 30)
//                    }
//                    .padding(3)
            }
        }
//        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear {
            coordinator.getSummeryInfo()
        }
    }
}

#Preview {
    SummeryView()
        .environmentObject(Coordinator())
}
