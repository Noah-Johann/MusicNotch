//
//  PermissionHelper.swift
//  MusicNotch
//
//  Created by Noah Johann
//

import Foundation
import ApplicationServices
import Carbon

class PermissionHelper {
    enum PermissionStatus {
        case closed, granted, notPrompted, denied
    }
    
    static func promptUserForConsent(for appBundleID: String, completion: @escaping (PermissionStatus) -> Void) {
        Task {
            let script = """
            tell application "Spotify"
                player state
            end tell
            """
            
            if let appleScript = NSAppleScript(source: script) {
                var error: NSDictionary?
                let result = appleScript.executeAndReturnError(&error)
                
                if let error = error {
                    print("AppleScript error: \(error)")
                    let errorCode = error["NSAppleScriptErrorNumber"] as? Int ?? 0
                    
                    if errorCode == -1743 {
                        Task { @MainActor in
                            completion(.denied)
                        }
                        return
                    } else {
                        Task { @MainActor in
                            completion(.closed)
                        }
                        return
                    }
                }
                
                print("AppleScript result: \(result.stringValue ?? "nil")")
                Task { @MainActor in
                    completion(.granted)
                }
            } else {
                Task { @MainActor in
                    completion(.closed)
                }
            }
        }
    }
}

enum AccessibilityHelper {
    static func isAuthorized(prompt: Bool = true) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}

