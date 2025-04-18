//
//  SettingsAcknowledgementsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.04.25.
//

import SwiftUI

struct SettingsAcknowledgementsView: View {
    var body: some View {
        aboutLicenseButton(name: "Luminare",
                           license: "BSD 3-Clause",
                           link: URL(string: "https://github.com/MrKai77/Luminare/tree/main")!,
                           image: "book"
        ) .frame( height: 40)
        aboutLicenseButton(name: "DynamicNotchKit",
                           license: "MIT",
                           link: URL(string: "https://github.com/MrKai77/DynamicNotchKit")!,
                           image: "book"
        ) .frame( height: 40)
        aboutLicenseButton(name: "KeyboardShortcuts",
                           license: "MIT",
                           link: URL(string: "https://github.com/sindresorhus/KeyboardShortcuts")!,
                           image: "book"
        ) .frame( height: 40)
        aboutLicenseButton(name: "LaunchAtLogin",
                           license: "MIT",
                           link: URL(string: "https://github.com/sindresorhus/LaunchAtLogin-Modern")!,
                           image: "book"
        ) .frame( height: 40)
        aboutLicenseButton(name: "Defaults",
                           license: "MIT",
                           link: URL(string: "https://github.com/sindresorhus/Defaults")!,
                           image: "book"
        ) .frame( height: 40)
        aboutLicenseButton(name: "Custom Slider Control",
                           license: "MIT",
                           link: URL(string: "https://github.com/pratikg29/Custom-Slider-Control")!,
                           image: "book"
        ) .frame( height: 40)
    }
}

#Preview {
    SettingsAcknowledgementsView()
}
