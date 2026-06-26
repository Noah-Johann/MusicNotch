//
//  SettingsMusicGlanceView.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.11.25.
//

import SwiftUI
import Luminare
import JochexUI
import Defaults

struct SettingsMusicGlanceView: View {
    /// Global music glance setting
    @Default(.globalMusicGlance) private var globalMusicGlance
    
    /// Player settings
    @Default(.amMusicGlance) private var amMusicGlance
    @Default(.spotifyMusicGlance) private var spotifyMusicGlance
    @Default(.npMusicGlance) private var npMusicGlance
    
    /// Settings type: - Per player or global
    @Default(.allPlayerMusicGlanceSetting) private var allPlayerMusicGlanceSetting
    
    @Default(.musicGlanceDuration) private var musicGlanceDuration
    
    /// Music Player for manuel selection
    @Default(.musicPlayer) private var musicPlayer
    
    @State private var musicManager = MusicManager.shared

    private var activeMusicGlancePlayer: MusicApp {
        Defaults[.autoPlayer] ? musicManager.musicPlayer : musicPlayer
    }

    private var musicGlanceBinding: Binding<Bool> {
        Binding(
            get: {
                if allPlayerMusicGlanceSetting {
                    return globalMusicGlance
                }

                switch activeMusicGlancePlayer {
                case .appleMusic: return amMusicGlance
                case .spotify: return spotifyMusicGlance
                case .nowPlaying: return npMusicGlance
                }
            },
            set: { newValue in
                if allPlayerMusicGlanceSetting {
                    globalMusicGlance = newValue
                } else {
                    switch activeMusicGlancePlayer {
                    case .appleMusic: amMusicGlance = newValue
                    case .spotify: spotifyMusicGlance = newValue
                    case .nowPlaying: npMusicGlance = newValue
                    }
                }
            }
        )
    }
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: musicGlanceBinding) {
                Text("Automatic MusicGlance")
                Spacer()
                Button { allPlayerMusicGlanceSetting.toggle() } label: {
                    Image(systemName: allPlayerMusicGlanceSetting ? "network" : "network.slash")
                        .foregroundStyle(.secondary)
                        .imageScale(.large)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
//                .luminarePopover() {
//                    Text("If deactivated, settings apply only for the currently selected player.")
//                        .padding()
//                }
            }
            
            if musicGlanceBinding.wrappedValue {
                LuminareSlider(
                    value: $musicGlanceDuration,
                    in: 1...10,
                    step: 1,
                    format: .number.precision(.fractionLength(0)),
                    suffix: Text("s")
                    
                ) {
                    Text("Display duration")
                }
                .padding(.vertical, 3)
            }
        } header: {
            Text("MusicGlance")
        }
    }
}

#Preview {
    SettingsMusicGlanceView()
}
