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
    
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showAlert = false
    @State private var success = false
    
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
                    if OnboardingPage == 3 {
                        LuminareSection() {
                            LuminareToggle("Launch at login", isOn: $launchAtLogin)
                        }
                    }
                    if OnboardingPage == 1 {
                        Button("Start setup") {
                            OnboardingPage += 1
                        } .buttonStyle(LuminareCompactButtonStyle())
                    } else if OnboardingPage == 2{
                        Button("Request permission") {
                            let consent = PermissionHelper.promptUserForConsent(for: "com.spotify.client")
                            switch consent {
                            case .granted:
                                alertTitle = Text("You are all set up!")
                                alertMessage = Text("Start playing a song!")
                                success = true
                                showAlert = true
                            case .closed:
                                alertTitle = Text("Spotify is not opened")
                                alertMessage = Text("Open Spotify to request permissions")
                                showAlert = true
                                success = false
                            case .denied:
                                alertTitle = Text("Permission denied")
                                alertMessage = Text("Please go to System Settings > Privacy & Security > Automation, and toggle Spotify under MusicNotch")
                                showAlert = true
                                success = false
                            case .notPrompted:
                                return
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: alertTitle, message: alertMessage, dismissButton: .default(Text("Got it!")) {
                                if success {
                                    OnboardingPage = 3
                                }
                            })
                        }
                        .buttonStyle(LuminareCompactButtonStyle())
                    } else if OnboardingPage == 3 {
                        Button("Finish") {
                            Defaults[.viewedOnboarding] = true  // Update in Defaults
                            WindowManager.closeOnboarding()
                            WindowManager.openSettings()
                        } .buttonStyle(LuminareCompactButtonStyle())
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
