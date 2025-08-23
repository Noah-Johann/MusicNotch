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
}

