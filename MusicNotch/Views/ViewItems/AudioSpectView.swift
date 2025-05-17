//
//  AudioSpectView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import SwiftUI

struct AudioSpectView: View {
    
    @ObservedObject var spotifyManager = SpotifyManager.shared

    var body: some View {
        AudioSpectrumView(isPlaying: $spotifyManager.isPlaying)
                            .foregroundStyle(.white)
                            .frame(width: 15, height: 15)
                            .padding(.horizontal, 10)
    }
}

#Preview {
    AudioSpectView()
}
