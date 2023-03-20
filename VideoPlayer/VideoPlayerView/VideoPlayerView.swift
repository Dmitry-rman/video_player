//
//  ContentView.swift
//  VideoPlayer
//
//  Created by Dmitry on 18.03.2023.
//

import SwiftUI

struct VideoPlayerView: View {
    
    @StateObject var viewModel: VideoPlayerViewModel
    @GestureState var translation: CGSize = .zero
    @State var touchMoveX: Double = 0
    @State var _prevX: Double = 0
    
    init(url: URL){
       _viewModel = StateObject(wrappedValue: VideoPlayerViewModel(url: url))
    }

    var body: some View {
        
        VStack {
            
            GeometryReader(){ reader in
                AVPlayerControllerRepresented(player: viewModel.player)
                    .gesture(DragGesture().updating($translation) { (value, state, _) in

                        DispatchQueue.main.async {
                            touchMoveX = (value.location.x - _prevX) / reader.size.width
                            _prevX = value.location.x
                        }
                    })
            }
            
            HStack{
                playButton
                let max = viewModel.isPlayerReady == true ? viewModel.duration : 1
                Slider(value: $viewModel.progressTime, in: 0...max)
                    .disabled(!viewModel.isPlayerReady)
                Text(viewModel.timeString)
            }.padding(.horizontal)
        }
        .onChange(of: viewModel.progressTime) { newValue in
            viewModel.seek(to: newValue)
        }
        .onChange(of: touchMoveX) { newValue in
            viewModel.progressTime += newValue * viewModel.duration
        }
    }
    
    private var playButton: some View{
        
        Button {
            viewModel.isPlaying ? viewModel.pause() : viewModel.play()
            viewModel.isPlaying.toggle()
            viewModel.seek(to: .zero)
        } label: {
            Image(systemName:  viewModel.isPlaying ? "stop" : "play")
                .padding()
        }
    }
    
}

#if DEBUG
struct ContentView_prevew: PreviewProvider{
    
    static let videoUrl =  Bundle.main.url(forResource: "vid", withExtension: "mp4")!
    
    static var previews: some View {
        VideoPlayerView(url: Self.videoUrl)
    }
}
#endif
