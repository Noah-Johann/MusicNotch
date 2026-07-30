//
//  OnboardingPage.swift
//  MusicNotch
//
//  Created by Noah Johann on 30.07.26.
//

import SwiftUI
import Defaults

enum OnboardingPage: Int {
    case start, permission, finish
    
    var title: LocalizedStringKey {
        switch self {
            case .start: "Welcome!"
            case .permission: "Permissions"
            case .finish: "All set up!"
        }
    }
    
    var body: Text {
        switch self {
            case .start:
                Text(
                    """
                    Thank you for downloading MusicNotch!
                        
                    Let's set up the App.
                    """
                )
            case .permission:
                Text("MusicNotch needs permission to control your music player.")
            case .finish:
                Text("Start playing a song!")
        }
    }
    
    var buttonTitle: LocalizedStringKey {
        switch self {
            case .start: "Start setup"
            case .permission: "Request permission"
            case .finish: "Finish"
        }
    }
    
    var buttonAction: () -> () {
        switch self {
            case .permission: {
                PermissionHelper.checkForAutomationPermission(appBundle: "com.apple.Music") { consent in
                    print("Apple Music Permission \(consent)")
                }
                PermissionHelper.checkForAutomationPermission(appBundle: "com.spotify.client") { consent in
                    print("Spotify Permission \(consent)")
                }
            }
            case .finish: {
                Defaults[.viewedOnboarding] = true
                WindowManager.shared.closeOnboarding()
                WindowManager.shared.openSettings()
            }
            default: {}
        }
    }
    
    var next: OnboardingPage? {
        OnboardingPage(rawValue: rawValue + 1)
    }
}
