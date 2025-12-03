//
//  SoundHelper.swift
//  MusicNotch
//
//  Created by Noah Johann on 22.11.25.
//

import Foundation
import AVFoundation
import AppKit

var soundPlayer: AVAudioPlayer?

func playSound(sound: Sound) {
    let name = sound.assetName

    guard let asset = NSDataAsset(name: name) else {
        print("Sound asset not found: \(name)")
        return
    }

    do {
        soundPlayer = try AVAudioPlayer(data: asset.data)
        soundPlayer?.prepareToPlay()
        soundPlayer?.play()
    } catch {
        print("Failed to play sound: \(error)")
    }
}

enum Sound: String {
    case lock
    case unlock

    var assetName: String {
        switch self {
        case .lock: return "lock"
        case .unlock: return "AutoUnlock_Haptic"
        }
    }
}

