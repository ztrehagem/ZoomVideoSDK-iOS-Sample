//
//  ContentView.swift
//  ZoomVideoSDK-iOS-Sample
//
//  Created by 諏訪 重貴 on 2024/08/26.
//

import SwiftUI
import ZoomVideoSDK

struct ContentView: View {
    @ObservedObject var room: Room
    
    var body: some View {
        VStack {
            HStack {
                RoomStateView(state: room.state)
                    .padding(.trailing)
                RoomActionView(state: room.state, onJoin: room.joinSession, onLeave: room.leaveSession)
                Spacer()
            }
            .padding()
            
            Spacer()

            Group {
                if case .joined = room.state {
                    SessionView(room: room)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct RoomStateView: View {
    var state: Room.State
    
    var body: some View {
        switch state {
        case .leaved:
            Text("LEAVED")
        case .joining:
            Text("JOINING")
        case .joined:
            Text("JOINED")
        }
    }
}

private struct RoomActionView: View {
    var state: Room.State
    var onJoin: () -> Void
    var onLeave: () -> Void
    
    var body: some View {
        switch state {
        case .leaved:
            Button(action: onJoin, label: {
                Text("JOIN")
            })
        case .joining:
            EmptyView()
        case .joined:
            Button(action: onLeave, label: {
                Text("LEAVE")
            })
        }
    }
}

private struct SessionView: View {
    @ObservedObject var room: Room
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 5)]) {
                ForEach(room.users, id: \.hash) { user in
                    VStack {
                        Text("\(user.getID())")
                        if let videoCanvas = user.getVideoCanvas() {
                            VideoView(videoCanvas: videoCanvas)
                                .frame(minWidth: 160, maxWidth: 1600)
                                .aspectRatio(16 / 9, contentMode: .fit)
                        }
                    }
                }
            }
        }
    }
}

private struct VideoView: UIViewRepresentable {
    typealias RawView = UIView
    
    var videoCanvas: ZoomVideoSDKVideoCanvas
    
    func makeCoordinator() -> Coordinator {
        Coordinator(videoCanvas: videoCanvas)
    }

    func makeUIView(context: Context) -> RawView {
        let view = RawView()

        context.coordinator.make(view)

        return view
    }

    func updateUIView(_ view: RawView, context: Context) {
        context.coordinator.update(view, videoCanvas: videoCanvas)
    }
    
    static func dismantleUIView(_ view: RawView, coordinator: Coordinator) {
        coordinator.dismantle(view)
    }
    
    class Coordinator {
        private var videoCanvas: ZoomVideoSDKVideoCanvas
        
        init(videoCanvas: ZoomVideoSDKVideoCanvas) {
            self.videoCanvas = videoCanvas
        }
        
        func make(_ view: RawView) {
            videoCanvas.subscribe(with: view, aspectMode: .letterBox, andResolution: ._Auto)
        }

        func update(_ view: RawView, videoCanvas newVideoCanvas: ZoomVideoSDKVideoCanvas) {
            if newVideoCanvas.isEqual(videoCanvas) {
                return
            }
            
            videoCanvas.unSubscribe(with: view)
            videoCanvas = newVideoCanvas
            videoCanvas.subscribe(with: view, aspectMode: .letterBox, andResolution: ._Auto)
        }
        
        func dismantle(_ view: RawView) {
            videoCanvas.unSubscribe(with: view)
        }
    }
}

