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
    
    /// Value of the settings toggle
    @State private var localMusicGlance: Bool = false
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $localMusicGlance) {
                Text("Automatic MusicGlance")
                Spacer()
                Button { allPlayerMusicGlanceSetting.toggle() } label: {
                    Image(systemName: allPlayerMusicGlanceSetting ? "network" : "network.slash")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .luminarePopover() {
                    Text("If deactivated, settings apply only for the currently selected player.")
                        .padding()
                }
            }
            .onAppear { refreshMusicGlanceToggle() }
            .onChange(of: allPlayerMusicGlanceSetting) { refreshMusicGlanceToggle() }
            .onChange(of: musicPlayer) { refreshMusicGlanceToggle() }
            .onChange(of: musicManager.musicPlayer) { if Defaults[.autoPlayer] { refreshMusicGlanceToggle() } }
            .onChange(of: localMusicGlance) { old, new in
                if allPlayerMusicGlanceSetting == true {
                    globalMusicGlance = new
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
                .padding(.vertical, 3)
            }
        } header: {
            Text("MusicGlance")
        }
        .padding(.bottom, 14)
    }
    
    func refreshMusicGlanceToggle() {
        if allPlayerMusicGlanceSetting {
            localMusicGlance = globalMusicGlance
        } else {
            if Defaults[.autoPlayer] {
                switch MusicManager.shared.musicPlayer {
                case .appleMusic: localMusicGlance = amMusicGlance
                case .spotify: localMusicGlance = spotifyMusicGlance
                case .nowPlaying: localMusicGlance = npMusicGlance
                }
            } else {
                switch musicPlayer {
                case .appleMusic: localMusicGlance = amMusicGlance
                case .spotify: localMusicGlance = spotifyMusicGlance
                case .nowPlaying: localMusicGlance = npMusicGlance
                }
            }
        }
    }
}

#Preview {
    SettingsMusicGlanceView()
}
