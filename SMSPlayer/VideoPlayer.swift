//
//  VideoPlayer.swift
//  SMSPlayer
//
//  Created by Md Shakhawat Hossain Shahin on 27/7/24.
//

import SwiftUI
import AVKit

struct VideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
//
//struct VideoPlayer_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayer()
//    }
//}
