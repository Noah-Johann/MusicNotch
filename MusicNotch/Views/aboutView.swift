//
//  aboutView.swift
//  MusicNotch
//
//  Created by Noah Johann on 09.04.25.
//

import SwiftUI
import Luminare

struct aboutView: View {
    var body: some View {
        LuminarePane {}
        content: {
            VStack(spacing: 0) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 130, height: 130)
                    .padding(.bottom, 13)

                VStack(spacing: 0) {
                    Text(Bundle.main.appName)
                        .blur(radius: 0)
                        .foregroundColor(.primary)
                        .font(.system(
                            size: 28,
                            weight: .bold
                        ))
                    Text("Version \(Bundle.main.appVersion!) (\(Bundle.main.appBuild!))")
                        .foregroundColor(Color(.tertiaryLabelColor))
                        .font(.body)
                        .padding(.top, 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                
                LuminareSection {
                    aboutButton(name: "GitHub",
                                role: "Contribute on Github",
                                link: URL(string: "https://github.com/Noah-Johann/MusicNotch")!,
                                image: Image("Github")
                    ) .frame(width: 250, height: 60)
                } .padding(.bottom, 20)
                VStack {
                    Text(Bundle.main.copyright)
                        .foregroundColor(Color(.tertiaryLabelColor))
                        .font(.body)
                        .padding(.top, 5)
                }
            }
            .padding(.horizontal, 24)
            
        } .frame(width: 300, height: 380)
    }
}

#Preview {
    aboutView()
}
