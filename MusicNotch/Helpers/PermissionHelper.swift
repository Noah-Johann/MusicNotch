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
    
    static func checkForAutomationPermission(appBundle: String, completion: @escaping (PermissionStatus) -> Void) {
        let status = AEDeterminePermissionToAutomateTarget(
            NSAppleEventDescriptor(bundleIdentifier: appBundle).aeDesc,
            typeWildCard,
            typeWildCard,
            true
        )
        
        switch status {
            case noErr: completion(.granted)
            case OSStatus(errAEEventNotPermitted): completion(.denied)
            case OSStatus(procNotFound): completion(.closed)
            default: completion(.notPrompted)
        }
    }
}

