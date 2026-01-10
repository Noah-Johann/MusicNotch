//
//  AppleScriptHelper.swift
//  MusicNotch
//
//  Created by Noah Johann on 21.08.25.
//

import Foundation

struct AppleScriptHelper {
    static func run(_ script: String) async throws {
        try await Task.detached(priority: .utility) {
            let task = Process()
            task.launchPath = "/usr/bin/osascript"
            task.arguments = ["-e", script]
            try task.run()
            task.waitUntilExit()
        }.value
    }
    
    static func executeAppleScript(_ script: String) -> NSAppleEventDescriptor? {
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?

        let result = appleScript?.executeAndReturnError(&error)

        if let error = error {
            print("AppleScript error: \(error)")
            return nil
        }

        return result
    }
}

