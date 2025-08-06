//
//  aboutView.swift
//  MusicNotch
//
//  Created by Noah Johann on 09.04.25.
//

import SwiftUI
import Luminare

struct aboutView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        LuminarePane () {
            VStack(spacing: 0) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 7)

                VStack(spacing: 0) {
                    Text(Bundle.main.appName)
                        .blur(radius: 0)
                        .foregroundStyle(.primary)
                        .font(.system(
                            size: 28,
                            weight: .bold
                        ))
                    Text("Version \(Bundle.main.appVersion!) (\(Bundle.main.appBuild!))")
                        .foregroundStyle(Color(.tertiaryLabelColor))
                        .font(.body)
                        .padding(.top, 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                LuminareSection {
                    aboutButton(name: "GitHub",
                                role: "Contribute on Github",
                                link: URL(string: "https://github.com/Noah-Johann/MusicNotch")!,
                                image: Image("Github")
                    ) .frame(width: 270, height: 60)
                } .padding(.bottom, 20)
                VStack {
                    Button {
                        openURL(URL(string: "https://github.com/Noah-Johann/MusicNotch/blob/main/LICENSE")!)
                    } label: {
                        Text("GPL 3.0 License")
                            .underline()
                    } .buttonStyle(.plain)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 5)

                    
                    Text(Bundle.main.copyright)
                        .foregroundStyle(Color(.tertiaryLabelColor))
                        .font(.body)
                }
            }
            .padding(.bottom, 5)
            
        } .frame(width: 320, height: 400)
            .scrollDisabled(true)
    }
}

#Preview {
    aboutView()
}
