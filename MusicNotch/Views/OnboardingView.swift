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
    
    @State private var OnboardingPage: Int = 1
    
    @Default(.launchAtLogin) private var launchAtLogin
    
    
    var body: some View {
        LuminarePane () {
            VStack (alignment: .center){
                HStack {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                    
                    if OnboardingPage == 1 {
                        Text("Welcome")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    } else if OnboardingPage == 2 {
                        Text("Permissions")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    } else if OnboardingPage == 3 {
                        Text("All set up!")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }
                } .padding(.bottom, 30)
                
                HStack {
                    if OnboardingPage == 1 {
                        Text("""
                             Thank you for downloading MusicNotch!
                            
                             Let's set up the App.
                            """)
                        .font(.system(size: 17, weight: .medium))
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .frame(width: 250)
                    }
                    
                    if OnboardingPage == 2 {
                        Text("MusicNotch needs access to Spotify to work properly.")
                            .font(.system(size: 17, weight: .medium))
                            .lineSpacing(6)
                            .multilineTextAlignment(.center)
                            .frame(width: 250)
                    }
                    
                    if OnboardingPage == 3 {
                        VStack {
                            Text("Start playing a song!")
                                .font(.system(size: 17, weight: .medium))
                                .lineSpacing(6)
                                .multilineTextAlignment(.center)
                                .frame(width: 250)
                                .padding(.bottom, 20)
                            
                            
                        }
                    }
                } .frame(height: 100)
                    .padding(.bottom, 30)
                
                
                HStack {
                    LuminareSection {
                        if OnboardingPage == 3 {
                            LuminareToggle(isOn: $launchAtLogin) {
                                Text("Launch at login")
                            }
                            
                        }
                        if OnboardingPage == 1 {
                            Button("Start setup") {
                                OnboardingPage += 1
                            } .buttonStyle(LuminareButtonStyle())
                        } else if OnboardingPage == 2 {
                            Button("Request permission") {
                                PermissionHelper.checkForAutomationPermission(appBundle: "com.apple.Music") { consent in
                                    print("Spotify Permission \(consent)")
                                }
                                PermissionHelper.checkForAutomationPermission(appBundle: "com.spotify.client") { consent in
                                    print("Spotify Permission \(consent)")
                                }
                                
                                OnboardingPage = 3
                            }
                            .buttonStyle(LuminareButtonStyle())
                        } else if OnboardingPage == 3 {
                            Button("Finish") {
                                Defaults[.viewedOnboarding] = true
                                WindowManager.shared.closeOnboarding()
                                WindowManager.shared.openSettings()
                            } .buttonStyle(LuminareProminentButtonStyle())
                        }
                    }
                    
                } .frame(width: 350, height: 40)
                    .padding(.bottom, 80)
                
            } .frame(width: 600, height: 380)
              .animation(.smooth, value: OnboardingPage)
            
        }.scrollDisabled(true)
    }
}



#Preview {
OnboardingView()
}
