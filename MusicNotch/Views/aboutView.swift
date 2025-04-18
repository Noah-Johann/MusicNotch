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
                    Button {
                        openURL(URL(string: "https://github.com/Noah-Johann/MusicNotch/blob/main/LICENSE")!)
                    } label: {
                        Text("GPL 3.0 License")
                            .underline()
                    } .buttonStyle(.plain)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 5)

                    
                    
                    Text(Bundle.main.copyright)
                        .foregroundColor(Color(.tertiaryLabelColor))
                        .font(.body)
                }
            }
            .padding(.horizontal, 24)
            
        } .frame(width: 300, height: 400)
            .scrollDisabled(true)
    }
}

#Preview {
    aboutView()
}
