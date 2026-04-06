//
//  SettingsMusicGlanceView.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.11.25.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsMusicGlanceView: View {
    @Default(.autoMusicGlance) private var autoMusicGlance
    @Default(.amMusicGlance) private var amMusicGlance
    @Default(.spotifyMusicGlance) private var spotifyMusicGlance
    @Default(.npMusicGlance) private var npMusicGlance
    @Default(.globalMusicGlance) private var globalMusicGlance
    @Default(.musicGlanceDuration) private var musicGlanceDuration
    @Default(.musicPlayer) private var musicPlayer
    
    @State private var localMusicGlance: Bool = false
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $localMusicGlance) {
                Text("Automatic MusicGlance")
                Spacer()
                Button { globalMusicGlance.toggle() } label: {
                    Image(systemName: globalMusicGlance ? "network" : "network.slash")
                        .foregroundStyle(.secondary)
                } .buttonStyle(.plain)
            }
            .onAppear { updateLocalMusicGlance() }
            .onChange(of: globalMusicGlance) { updateLocalMusicGlance() }
            .onChange(of: musicPlayer) { updateLocalMusicGlance() }
            .onChange(of: localMusicGlance) { old, new in
                if globalMusicGlance == true {
                    autoMusicGlance = new
                } else {
                    switch musicPlayer {
                    case .appleMusic: amMusicGlance = new
                    case .spotify: spotifyMusicGlance = new
                    case .nowPlaying: npMusicGlance = new
                    }
                }
            }
            
            if localMusicGlance {
                LuminareSlider(
                    value: $musicGlanceDuration,
                    in: 1...10,
                    step: 1,
                    format: .number.precision(.fractionLength(0)),
                    suffix: Text("s")
                    
                ) {
                    Text("Display duration")
                }
                .luminareSliderLayout(.compact)
                .padding(.vertical, 3)
            }
        } header: {
            Text("MusicGlance")
        }
        .padding(.bottom, 14)
    }
    
    func updateLocalMusicGlance() {
        if globalMusicGlance {
            localMusicGlance = autoMusicGlance
        } else {
            switch musicPlayer {
            case .appleMusic: localMusicGlance = amMusicGlance
            case .spotify: localMusicGlance = spotifyMusicGlance
            case .nowPlaying: localMusicGlance = npMusicGlance
            }
        }
    }
}

#Preview {
    SettingsMusicGlanceView()
}
