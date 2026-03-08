//
//  SettingsMusicView.swift
//  MusicNotch
//
//  Created by Noah Johann on 01.01.26.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsMusicView: View {
    @Default(.autoPlayer) private var autoPlayer
    @Default(.musicPlayer) private var musicPlayer
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $autoPlayer) {
                HStack {
                    Image(systemName: "music.quarternote.3")
                        .bold()
                        .foregroundStyle(autoPlayer ? Color.accentColor : Color.gray)
                    Text("Auto player")
                    if autoPlayer {
                        Group {
                            Image(systemName: "ellipsis")
                            Text(MusicManager.shared.musicPlayer.text)
                        } .foregroundStyle(Color.gray)
                    }
                }
            }
            if !autoPlayer {
                LuminarePicker(
                    elements: MusicApp.allCases,
                    selection: Binding(
                        get: { Defaults[.musicPlayer] },
                        set: { Defaults[.musicPlayer] = $0 }
                    ),
                    columns: 3
                ) { option in
                    VStack(spacing: 12) {
                        option.image
                        Text(option.text)
                            .font(.title3)
                    }
                }
                .luminareRoundingBehavior(bottom: true)
                .luminareBorderedStates(.none)
                .frame(height: 110)
            }
        } header: {
            Text("Music")
        }
        .padding(.bottom, 14)
        .onChange(of: musicPlayer) {
            SpotifyManager.shared.oldTrackName = "notrack"
            MusicManager.shared.updateMusic(player: musicPlayer)
        }
    }
}

#Preview {
    SettingsMusicView()
}
