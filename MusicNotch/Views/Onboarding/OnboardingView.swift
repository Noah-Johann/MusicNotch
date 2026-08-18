//
//  OnboardingView.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.04.25.
//

import SwiftUI
import Luminare
import ScriptingBridge
import Defaults

struct OnboardingView: View {
    
    @State private var onboardingPage: OnboardingPage = .start
    
    @Default(.launchAtLogin) private var launchAtLogin
    
    var body: some View {
        VStack (alignment: .center, spacing: 30) {
            HStack(spacing: 15) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                
                Text(onboardingPage.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
            }
        
            onboardingPage.body
                .font(.system(size: 17, weight: .medium))
                .lineSpacing(6)
                .multilineTextAlignment(.center)
                .frame(width: 250, height: 100)
            
            LuminareSection {
                if onboardingPage == .finish {
                    LuminareToggle(isOn: $launchAtLogin) {
                        Text("Launch at login")
                    }
                }
                
                Button {
                    onboardingPage.buttonAction()
                    
                    if let next = onboardingPage.next {
                        onboardingPage = next
                    }
                } label: {
                    Text(onboardingPage.buttonTitle)
                }
                .buttonStyle(.luminare)
                .luminareRoundingBehavior(top: onboardingPage == .finish ? false : true, bottom: true)
                .frame(height: 32)
            }
            .frame(width: 350, height: 72, alignment: .bottom)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.smooth, value: onboardingPage)
        
    }
}



#Preview {
OnboardingView()
}
