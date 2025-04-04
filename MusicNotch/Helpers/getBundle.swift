//
//  getBundle.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.04.25.
//

import Foundation

// Returns the current build number
extension Bundle {
    var appName: String {
        getInfo("CFBundleName") ?? "ERROR"
    }

    var displayName: String {
        getInfo("CFBundleDisplayName") ?? "ERROR"
    }

    var bundleID: String {
        getInfo("CFBundleIdentifier") ?? "ERROR"
    }

    var copyright: String {
        getInfo("NSHumanReadableCopyright") ?? "ERROR"
    }

    var appBuild: Int? {
        Int(getInfo("CFBundleVersion") ?? "")
    }

    var appVersion: String? {
        getInfo("CFBundleShortVersionString")
    }

    func getInfo(_ str: String) -> String? {
        infoDictionary?[str] as? String
    }
}

