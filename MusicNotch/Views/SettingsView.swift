//
//  SettingsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 27.03.25.
//

import Foundation
import SwiftUI
import Luminare
import Defaults
import LaunchAtLogin

struct SettingsView: View {
    
    @Default(.hideNotchTime) private var hideNotchTime
    @Default(.notchSizeChange) private var notchSizeChange
    @Environment(\.openURL) private var openURL


    var body: some View {
        VStack {
            LuminareSection("General") {
                LuminareToggle(
                    "Launch at login",
                    isOn: Binding(
                        get: { LaunchAtLogin.isEnabled },
                        set: { value in LaunchAtLogin.isEnabled = value }
                    )
                )
            } .padding(.bottom, 7)              
            LuminareSection("Notch") {
            } .padding(.bottom, 7)
            LuminareSection("About") {
                aboutAppButton()
                    .frame(height: 75)
            } .padding(.bottom, 7)
            LuminareSection() {
                aboutButton(name: "Noah Johann",
                            role: "Development",
                            link: URL(string: "https://github.com/Noah-Johann")!,
                            image: Image("Credit")
                ) .frame(height: 60)
                aboutButton(name: "Github",
                            role: "Contribute on Github",
                            link: URL(string: "https://github.com/Noah-Johann/MusicNotch")!,
                            image: Image("Github")
                ) .frame( height: 60)
            }
            Text(Bundle.main.copyright)
                .padding()
                .font(.caption)
                .foregroundStyle(.secondary)
        } .padding(30)
    }
    
    @ViewBuilder
    func aboutButton(name: String, role: String, link: URL, image: Image) -> some View {
        Button {
            openURL(link)
        } label: {
            HStack(spacing: 12) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .overlay {
                        Circle()
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    }
                    .clipShape(.circle)

                VStack(alignment: .leading) {
                    Text(name)

                    Text(role)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                }

                Spacer()

            }
            .padding(12)
        }
        .buttonStyle(LuminareCosmeticButtonStyle(Image(systemName: "arrow.up.right")))
    }
    
    func aboutAppButton() -> some View {
        Button {
            copyInfo()
        } label: {
            HStack(spacing: 12) {
                Image("AboutIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)


                VStack(alignment: .leading) {
                    Text(Bundle.main.appName)
                    Text("Version: \(Bundle.main.appVersion!) (\(Bundle.main.appBuild!))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                }

                Spacer()
            }
            .padding(4)
        }
        .buttonStyle(LuminareCosmeticButtonStyle(Image(systemName: "clipboard")))
    }
}
#Preview {
    SettingsView()
}
