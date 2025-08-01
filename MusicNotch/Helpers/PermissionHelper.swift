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
    
    static func promptUserForConsent(for appBundleID: String, completion: @Sendable @escaping (PermissionStatus) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
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
                        DispatchQueue.main.async {
                            completion(.denied)
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            completion(.closed)
                        }
                        return
                    }
                }

                print("AppleScript result: \(result.stringValue ?? "nil")")
                DispatchQueue.main.async {
                    completion(.granted)
                }
            } else {
                DispatchQueue.main.async {
                    completion(.closed)
                }
            }
        }
    }
}

