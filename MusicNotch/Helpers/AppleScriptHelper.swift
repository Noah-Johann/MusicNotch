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
    
    static func executeAppleScript(_ script: String) -> Any? {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-ss", "-e", script]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            }
        } catch {
            print("AppleScript-Error: \(error)")
        }
        return nil
    }
}

