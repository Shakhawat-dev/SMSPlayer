//
//  ContentView.swift
//  SMSPlayer
//
//  Created by Md Shakhawat Hossain Shahin on 27/7/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let safeArea = geo.safeAreaInsets
            
            HomeView(size: size, safeArea: safeArea)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
