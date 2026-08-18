//
//  BrightnessManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 13.09.25.
//

import AppKit
import IOKit
import CoreGraphics
import Defaults
import SwiftUI

@Observable
class BrightnessManager {
    static let shared = BrightnessManager()
    
    var brightness: CGFloat = 0
    
    private var bdManager = BetterDisplayManager()
    

    init() {
        registerForBrightnessChange()
    }
    
    deinit {
        unregisterForBrightnessChange()
    }

    
    public func updateBrightness() {
        guard !bdManager.isBDRunning else { return }
        self.brightness = CGFloat(getCurrentBrightness() ?? -1)
        Task {
            NotchManager.shared.showExtensionNotch(type: .brightness, duration: Defaults[.displayDuration])
        }
    }
    
    
    private func getCurrentBrightness() -> Float? {
        let displayID = CGMainDisplayID()
        
        guard let sym = dlsym(DisplayServicesHandle.handle, "DisplayServicesGetBrightness") else { return nil }
        
        typealias Fn = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32
        let fn = unsafeBitCast(sym, to: Fn.self)
        var brightness: Float = 0
        
        return fn(displayID, &brightness) == 0 ? brightness : nil
    }


    private func registerForBrightnessChange() {
        guard let sym = dlsym(DisplayServicesHandle.handle, "DisplayServicesRegisterForBrightnessChangeNotifications") else { return }
        typealias Fn = @convention(c) (CGDirectDisplayID, UnsafeMutableRawPointer?, @convention(c) (CGDirectDisplayID, Float) -> Void) -> Int32
        let fn = unsafeBitCast(sym, to: Fn.self)

        // Set your handler before registering
        brightnessChangeHandler = { displayID, brightness in
            self.updateBrightness()
        }

        let result = fn(CGMainDisplayID(), nil, staticBrightnessCallback)
        print("registered: \(result)")
    }
    
    
    func unregisterForBrightnessChange() {
        guard let sym = dlsym(DisplayServicesHandle.handle, "DisplayServicesUnregisterForBrightnessChangeNotifications") else { return }
        typealias Fn = @convention(c) (CGDirectDisplayID, @convention(c) (CGDirectDisplayID, Float) -> Void) -> Int32
        let fn = unsafeBitCast(sym, to: Fn.self)

        let result = fn(CGMainDisplayID(), staticBrightnessCallback)
        brightnessChangeHandler = nil
        print("unregistered: \(result)")
    }

    
    private enum DisplayServicesHandle {
        static let handle: UnsafeMutableRawPointer? = {
            let paths = [
                "/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices",
                "/System/Library/PrivateFrameworks/DisplayServices.framework/Versions/Current/DisplayServices"
            ]
            for path in paths {
                if let handle = dlopen(path, RTLD_LAZY) { return handle }
            }
            return nil
        }()
    }
}

var brightnessChangeHandler: ((CGDirectDisplayID, Float) -> Void)?

private let staticBrightnessCallback: @convention(c) (CGDirectDisplayID, Float) -> Void = { displayID, brightness in
    brightnessChangeHandler?(displayID, brightness)
}




