//
//  AudioSpectView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import SwiftUI
import Defaults

struct AudioSpectView: View {
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @Default(.coloredSpect) private var coloredSpect
    
    var body: some View {
        Rectangle()
            .fill(coloredSpect ? Color(nsColor: spotifyManager.aveColor ?? .white).gradient : Color.white.gradient)
            .frame(width: 35, alignment: .center)
            .mask {
                AudioSpectrumView(isPlaying: $spotifyManager.isPlaying)
                    .frame(width: 15, height: 16)
            }
    }
}

#Preview {
    AudioSpectView()
}
