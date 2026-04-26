//
//  NotchAirPodsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.11.25.
//

import SwiftUI
import AVKit
import Defaults

struct NotchAirPodsViewLeading: View {
    @State private var volumeManager = VolumeManager.shared
    @State private var accessibilityManager = AccessibilityManager.shared
    
    @Default(.bluetoothSymbols) private var bluetoothSymbols

    var body: some View {
        if bluetoothSymbols || accessibilityManager.isReduceMotion {
            Image(systemName: volumeManager.deviceIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        } else {
            if let path = Bundle.main.path(forResource: volumeManager.deviceVideo, ofType: "mp4") {
                let url = URL(fileURLWithPath: path)
                VideoView(url: url)
                    .frame(width: 33, height: 33)
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Video not found")
            }
        }
    }
}

struct NotchAirPodsViewTrailing: View {
    var body: some View {
        BatteryRingView()
            .frame(width: 30, height: 30)
    }
}

//#Preview {
//
//}

struct VideoView: NSViewRepresentable {
    let url: URL

    final class PlayerHostingView: NSView {
        let player: AVPlayer
        let playerLayer: AVPlayerLayer
        init(url: URL) {
            self.player = AVPlayer(url: url)
            self.player.isMuted = true
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer.videoGravity = .resizeAspect
            super.init(frame: .zero)
            self.wantsLayer = true
            self.layer = CALayer()
            self.playerLayer.frame = self.bounds
            self.playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            self.layer?.addSublayer(self.playerLayer)
        }
        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }

    final class Coordinator {
        var endObserver: Any?
        deinit {
            if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSView {
        let hostingView = PlayerHostingView(url: url)
        hostingView.player.play()
        context.coordinator.endObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                                 object: hostingView.player.currentItem,
                                                                                 queue: .main) { _ in
            hostingView.player.seek(to: .zero)
            hostingView.player.play()
        }
        return hostingView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let hostingView = nsView as? PlayerHostingView {
            hostingView.playerLayer.frame = hostingView.bounds
        }
    }
}
