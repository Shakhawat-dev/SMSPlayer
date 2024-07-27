//
//  HomeView.swift
//  SMSPlayer
//
//  Created by Md Shakhawat Hossain Shahin on 27/7/24.
//

import SwiftUI
import AVKit

struct HomeView: View {
    var size: CGSize
    var safeArea: EdgeInsets
    
    @State var player: AVPlayer? = {
        if let bundle = Bundle.main.path(forResource: "video", ofType: "mov") {
            return AVPlayer(url: URL(filePath: bundle))
        }
        
        return nil
    }()
    
    @State private var showPlayerControls: Bool = false
    @State private var isPlaying: Bool = false
    
    @State private var timeoutTask: DispatchWorkItem?
    
    // Video seek properties
    @GestureState private var isDragging: Bool = false
    @State private var isSeeking: Bool = false
    @State private var progress: CGFloat = 0
    @State private var lastDraggedProgress: CGFloat = 0
    
    
    var body: some View {
        VStack {
            let videoPlayerSize: CGSize = .init(width: size.width, height: size.height / 3.5)
            
            ZStack {
                if let player {
                    VideoPlayer(player: player)
                        .overlay {
                            Rectangle()
                                .fill(.black.opacity(0.4))
                                .opacity(showPlayerControls || isDragging ? 1 : 0)
                                .animation(.easeInOut(duration: 0.35), value: isDragging)
                                .overlay {
                                    PlayBackControls()
                                }
                            
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                showPlayerControls.toggle()
                            }
                            
                            if isPlaying {
                                timeoutControls()
                            }
                        }
                        .overlay(alignment: .bottom) {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("\(NSString(format: "%02d:%02d", Int(player.currentTime().seconds) / 60, Int(player.currentTime().seconds) % 60 ) as String)")
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                        .padding(.leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "fullscreen.fill")
                                }
                                
                                VideoSeekerView(size)
                                    .padding(.vertical)
                            }
                            
                        }
                }
            }
            .frame(width: videoPlayerSize.width, height: videoPlayerSize.height)
        }
        .onAppear() {
            player?.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: 1), queue: .main, using: { time in
                if let currentPlayerItem = player?.currentItem {
                    let totalDuration = currentPlayerItem.duration.seconds
                    
                    guard let currentDuration = player?.currentTime().seconds else { return }
                    
                    let calculatedProgrss = currentDuration / totalDuration
                    
                    
                    if !isSeeking {
                        progress = calculatedProgrss
                        lastDraggedProgress = progress
                        
                    }
                }
            })
        }
    }
    
    @ViewBuilder
    func VideoSeekerView(_ videoSize: CGSize) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(.gray)
            
            Rectangle()
                .fill(.red)
                .frame(width: max(size.width * progress, 0))
        }
        .frame(height: 3)
        .overlay(alignment: .leading) {
            Circle()
                .fill(.red)
                .frame(width: 15, height: 15)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
                .offset(x: size.width * progress)
                .gesture(DragGesture().updating($isDragging, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    if let timeoutTask {
                        timeoutTask.cancel()
                    }
                    
                    let transitionX: CGFloat = value.translation.width
                    let calculetedProgress = (transitionX / videoSize.width) + lastDraggedProgress
                    
                    progress = max(min(calculetedProgress, 1), 0)
                    isSeeking = true
                }).onEnded({ value in
                    lastDraggedProgress = progress
                    
                    if let currentPlayerItem = player?.currentItem {
                        let totalDuration = currentPlayerItem.duration.seconds
                        
                        player?.seek(to: .init(seconds: totalDuration * progress, preferredTimescale: 1))
                        
                        if isPlaying {
                            timeoutControls()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isSeeking = false
                        }
                    }
                })
                )
                .frame(width: 15, height: 15)
        }
    }
    
    @ViewBuilder
    func PlayBackControls() -> some View {
        HStack {
            Button {
                // Action
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.white)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(.black.opacity(0.33))
                    }
            }
            
            Button {
                // Action
                if isPlaying {
                    player?.pause()
                    
                    // Cacelling timeout task when the video is paused
                    if let timeoutTask {
                        timeoutTask.cancel()
                    }
                } else {
                    player?.play()
                    timeoutControls()
                }
                
                withAnimation(.easeInOut(duration: 0.25)) {
                    isPlaying.toggle()
                }
            } label: {
                Image(systemName: !isPlaying ? "play.fill" : "pause.fill")
                    .font(.title)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.black)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(.white)
                    }
            }

            
            Button {
                // Action
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.white)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(.black.opacity(0.33))
                    }
            }
        }
        .opacity(showPlayerControls && !isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: showPlayerControls && !isDragging)
    }
    
    func timeoutControls() {
        if let timeoutTask {
            timeoutTask.cancel()
        }
        
        timeoutTask = .init(block: {
            withAnimation(.easeInOut(duration: 0.35)) {
                showPlayerControls = false
                
            }
        })
        
        if let timeoutTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: timeoutTask)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
//        HomeView()
        ContentView()
    }
}
