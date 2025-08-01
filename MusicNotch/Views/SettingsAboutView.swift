//
//  SettingsAboutView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.04.25.
//

import SwiftUI

@MainActor
struct SettingsAboutView: View {
    var body: some View {
        aboutButton(name: "Noah Johann",
                    role: "Development",
                    link: URL(string: "https://github.com/Noah-Johann")!,
                    image: Image("Credit")
        ) .frame(height: 60)
        
        aboutButton(name: "GitHub",
                    role: "Contribute on Github",
                    link: URL(string: "https://github.com/Noah-Johann/MusicNotch")!,
                    image: Image("Github")
        ) .frame( height: 60)
    }
}

#Preview {
    SettingsAboutView()
}
