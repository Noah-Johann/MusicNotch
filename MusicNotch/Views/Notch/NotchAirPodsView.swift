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
            if let url = Bundle.main.url(forResource: volumeManager.deviceVideo, withExtension: "mp4") {
                VideoView(url: url)
                    .frame(width: 33, height: 33)
                    .allowsHitTesting(false)
            } else {
                Image(systemName: volumeManager.deviceIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
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

private struct VideoView: NSViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.configure(with: url, coordinator: context.coordinator)
        return view
    }

    func updateNSView(_ nsView: PlayerView, context: Context) {
        nsView.configure(with: url, coordinator: context.coordinator)
    }

    static func dismantleNSView(_ nsView: PlayerView, coordinator: Coordinator) {
        coordinator.removeEndObserver()
        nsView.player.pause()
        nsView.playerLayer.player = nil
    }

    final class Coordinator {
        private var endObserver: Any?

        func loop(_ item: AVPlayerItem, player: AVPlayer) {
            removeEndObserver()
            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }

        func removeEndObserver() {
            if let endObserver {
                NotificationCenter.default.removeObserver(endObserver)
                self.endObserver = nil
            }
        }

        deinit {
            removeEndObserver()
        }
    }

    final class PlayerView: NSView {
        let player = AVPlayer()
        let playerLayer = AVPlayerLayer()
        private var currentURL: URL?

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer = CALayer()
            player.isMuted = true
            player.actionAtItemEnd = .none
            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspect
            layer?.addSublayer(playerLayer)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layout() {
            super.layout()
            playerLayer.frame = bounds
        }

        func configure(with url: URL, coordinator: Coordinator) {
            guard currentURL != url else {
                player.play()
                return
            }

            currentURL = url
            let item = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: item)
            coordinator.loop(item, player: player)
            player.play()
        }
    }
}
