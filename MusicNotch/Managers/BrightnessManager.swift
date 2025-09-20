//
//  BrightnessManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 13.09.25.
//

import AppKit
import IOKit
import CoreGraphics

class BrightnessManager: ObservableObject {
    
    static let shared = BrightnessManager()
    
    @Published var brightness: CGFloat = 0
    
    public func UpBrightness() {
        
        Task { @MainActor in
            NotchManager.shared.showExtensionNotch(type: .brightness)
        }
    }
    
    public func DownBrightness() {
        
        Task { @MainActor in
            NotchManager.shared.showExtensionNotch(type: .brightness)
        }
    }
    
    public func updateBrightness() {
        self.brightness = CGFloat(getCurrentBrightness() ?? -1)
    }
    
    
    private func getCurrentBrightness() -> Float? {
        let displayID = CGMainDisplayID()
        
        // Try DisplayServices first
        if let brightness = getDisplayServicesBrightness(displayID: displayID) {
            return brightness
        }
        
        // Fall back to IOKit
        if let brightness = getIOKitBrightness(displayID: displayID) {
            return brightness
        }
        
        return nil
    }
    
    private func getDisplayServicesBrightness(displayID: CGDirectDisplayID) -> Float? {
        guard let handle = getDisplayServicesHandle(),
              let sym = dlsym(handle, "DisplayServicesGetBrightness") else {
            return nil
        }
        
        typealias Fn = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32
        let fn = unsafeBitCast(sym, to: Fn.self)
        var brightness: Float = 0
        
        return fn(displayID, &brightness) == 0 ? brightness : nil
    }
    
    private func getIOKitBrightness(displayID: CGDirectDisplayID) -> Float? {
        guard let service = getIOServiceForDisplay(displayID: displayID) else {
            return nil
        }
        
        var brightness: Float = 0
        let result = IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
        IOObjectRelease(service)
        
        return result == kIOReturnSuccess ? brightness : nil
    }
    
    private func getDisplayServicesHandle() -> UnsafeMutableRawPointer? {
        let paths = [
            "/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices",
            "/System/Library/PrivateFrameworks/DisplayServices.framework/Versions/Current/DisplayServices"
        ]
        
        for path in paths {
            if let handle = dlopen(path, RTLD_LAZY) {
                return handle
            }
        }
        return nil
    }
    
    private func getIOServiceForDisplay(displayID: CGDirectDisplayID) -> io_service_t? {
        var iterator: io_iterator_t = 0
        let matching = IOServiceMatching("IODisplayConnect")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == kIOReturnSuccess else {
            return nil
        }
        
        defer { IOObjectRelease(iterator) }
        
        let targetVendorID = CGDisplayVendorNumber(displayID)
        let targetProductID = CGDisplayModelNumber(displayID)
        
        while case let service = IOIteratorNext(iterator), service != 0 {
            defer { IOObjectRelease(service) }
            
            guard let info = IODisplayCreateInfoDictionary(service, 0)?.takeRetainedValue() as? NSDictionary,
                  let vendorID = info[kDisplayVendorID] as? UInt32,
                  let productID = info[kDisplayProductID] as? UInt32 else {
                continue
            }
            
            if vendorID == targetVendorID && productID == targetProductID {
                // Need to retain the service before returning since we're releasing it in defer
                IOObjectRetain(service)
                return service
            }
        }
        
        return nil
    }
}
