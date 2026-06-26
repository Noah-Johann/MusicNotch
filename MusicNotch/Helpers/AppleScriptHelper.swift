//
//  AppleScriptHelper.swift
//  MusicNotch
//
//  Created by Noah Johann on 21.08.25.
//

import Foundation

struct AppleScriptHelper {
    static func run(_ script: NSAppleScript) async throws {
        _ = await executeAppleScript(script)
    }
    
    static func executeAppleScript(_ script: NSAppleScript) async -> NSAppleEventDescriptor? {
        await withCheckedContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                var error: NSDictionary?

                let result = script.executeAndReturnError(&error)

                if let error {
                    print("AppleScript error: \(error)")
                }

                continuation.resume(returning: result)
            }
        }
    }
}

