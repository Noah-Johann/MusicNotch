//
//  SettingsAboutView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.04.25.
//

import SwiftUI
import Luminare

struct SettingsAboutView: View {
    var body: some View {
        LuminareSection {
            aboutAppButton()
                .frame(height: 75)
        } header: {
            Text("About")
        }.padding(.bottom, 7)
        
        LuminareSection {
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
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsAboutView()
}
