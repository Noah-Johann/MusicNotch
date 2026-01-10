//
//  BrightnessManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 13.09.25.
//

import AppKit
import IOKit
import CoreGraphics

@MainActor
final class BrightnessManager: ObservableObject {
    
    static let shared = BrightnessManager()
    
    @Published var brightness: CGFloat = 0
    
    private var betterDisplay: Bool = false
    
    init() {
        betterDisplay = checkIfBetterDisplay()
        
        if betterDisplay {
            setupBetterDisplayObserver()
        }
    }
    
// MARK: - BetterDisplay
    
    private func checkIfBetterDisplay() -> Bool {
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: "pro.betterdisplay.BetterDisplay") != nil
    }
    
    private func setupBetterDisplayObserver() {
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(betterDisplayNotificaiton), name: .init("com.betterdisplay.BetterDisplay.osd"), object: nil)
    }
    
    @objc private func betterDisplayNotificaiton(notification: NSNotification) {
        guard let notificationString = notification.object as? String else {
            return
        }
        do {
            let notification = try JSONDecoder().decode(BetterDisplayNotification.self, from: Data(notificationString.utf8))
            if let type = notification.controlTarget, type.contains("Brightness") {
                self.brightness = (notification.value ?? 0) / (notification.maxValue ?? 0)
                Task { @MainActor in
                    NotchManager.shared.showExtensionNotch(type: .brightness)
                }
            }
        } catch {}
    }
    
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

struct BetterDisplayNotification: Codable {
  var displayID: Int? = nil // Which display should show the OSD
  var systemIconID: Int? = nil // 1 - brightness, 3 - volume, 4 - mute, 0 - no icon
  var customSymbol: String? = nil // SF Symbol name if a custom icon is used
  var text: String? = nil // Text if additional text is displayed in the OSD HUD by the app
  var lock: Bool? = nil // Shows lock icon as well
  var controlTarget: String? = nil // Further description of the type of control the OSD is displayed for
  var value: Double? = nil // OSD value (scale: 0-max value)
  var maxValue: Double? = nil // max value
  var symbolFadeAfter: Int? = nil // If the symbol is a secondary symbol, it should be faded after this time elapsed - in milliseconds
  var symbolSizeMultiplier: Double? = nil // Symbol size adjustment (compared to normal size)
  var textFadeAfter: Int? = nil // Text should be faded after this time elapsed - in milliseconds
}
