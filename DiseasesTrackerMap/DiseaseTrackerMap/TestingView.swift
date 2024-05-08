//
//  TestingView.swift
//  DiseaseTrackerMap
//
//  Created by Taewon Yoon on 5/4/24.
//

import SwiftUI

struct TestingView: View {
    
    @Environment(Testing.self) var testing
    
    var body: some View {
        
        Button {
            testing.tapped.toggle()
        } label: {
            Text("버튼")
        }
    }
}

#Preview {
    TestingView()
}
