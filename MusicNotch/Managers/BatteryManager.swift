//
//  BatteryManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import Foundation
import IOKit.ps
import SwiftUI
import Defaults

class BatteryManager {
    static let shared = BatteryManager()
    
    @Published var isCharging: Bool = false
    @Published var isLowPowerMode: Bool = false
    @Published var currentCapacity: Double = 0
    
    @Published var BatteryIconColor: Color = .white
    @Published var BatteryIconName: String = "battery.100percent"
    
    private var batterySource: CFRunLoopSource?
    
    // Use when no battery information is available
    private let errorBatteryInfo = BatteryInfo(
        isPluggedIn: false,
        isCharging: false,
        currentCapacity: 1,
        maxCapacity: 100,
        isInLowPowerMode: false,
        timeToFullCharge: 1
    )
    
    enum BatteryError: Error {
        case powerSourceUnavailable
        case batteryInfoUnavailable(String)
        case batteryParameterMissing(String)
    }
    
    init() {
        setupObservers()
        startMonitoring()
    }
//    deinit {
//        
//    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(lowPowerModeChanged),
            name: NSNotification.Name.NSProcessInfoPowerStateDidChange,
            object: nil
        )
    }
    
    private func startMonitoring() {
        guard let powerSource = IOPSNotificationCreateRunLoopSource({ context in
            guard let context = context else { return }
            let manager = Unmanaged<BatteryManager>.fromOpaque(context).takeUnretainedValue()
            manager.updateBatteryInfo()
        }, Unmanaged.passUnretained(self).toOpaque())?.takeRetainedValue() else {
            return
        }
        batterySource = powerSource
        CFRunLoopAddSource(CFRunLoopGetCurrent(), powerSource, .defaultMode)
    }
    
    @objc private func lowPowerModeChanged() {
        print("low power mode notification")
        updateBatteryInfo()
    }
    
    func updateBatteryInfo() {
        guard Defaults[.batteryExtension] == true else { return }
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
            } catch {
                return
            }
        }
        
        let info = getBatteryInfo()
        
        self.currentCapacity = Double(info.currentCapacity)
        
        if info.isPluggedIn == true && info.isInLowPowerMode == true {
            self.BatteryIconName = "battery.100percent.bolt"
            self.BatteryIconColor = .yellow
        } else if info.isPluggedIn == true && info.isInLowPowerMode == false {
            self.BatteryIconName = "battery.100percent.bolt"
            self.BatteryIconColor = .green
        } else if info.isPluggedIn == false && info.isInLowPowerMode == true {
            self.BatteryIconName = "battery.100percent"
            self.BatteryIconColor = .yellow
        } else {
            self.BatteryIconName = "battery.100percent"
            self.BatteryIconColor = .white
        }
        
        Task { @MainActor in
            NotchManager.shared.showExtensionNotch(type: .battery)
        }
        
    }
    
    private func getBatteryInfo() -> BatteryInfo {
        do {
            // Get power source information
            guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
                throw BatteryError.powerSourceUnavailable
            }
            
            guard let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
                !sources.isEmpty else {
                throw BatteryError.batteryInfoUnavailable("No power sources available")
            }
            
            let source = sources.first!
            
            guard let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] else {
                throw BatteryError.batteryInfoUnavailable("Could not get power source description")
            }
            
            // Extract required battery parameters with error handling
            guard let currentCapacity = description[kIOPSCurrentCapacityKey] as? Float else {
                throw BatteryError.batteryParameterMissing("Current capacity")
            }
            
            guard let maxCapacity = description[kIOPSMaxCapacityKey] as? Float else {
                throw BatteryError.batteryParameterMissing("Max capacity")
            }
            
            guard let isCharging = description["Is Charging"] as? Bool else {
                throw BatteryError.batteryParameterMissing("Charging state")
            }
            
            guard let powerSource = description[kIOPSPowerSourceStateKey] as? String else {
                throw BatteryError.batteryParameterMissing("Power source state")
            }
            
            // Create battery info with the extracted parameters
            var batteryInfo = BatteryInfo(
                isPluggedIn: powerSource == kIOPSACPowerValue,
                isCharging: isCharging,
                currentCapacity: currentCapacity,
                maxCapacity: maxCapacity,
                isInLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
                timeToFullCharge: 0
            )
            
            // Optional parameters
            if let timeToFullCharge = description[kIOPSTimeToFullChargeKey] as? Int {
                batteryInfo.timeToFullCharge = timeToFullCharge
            }
            
            return batteryInfo
            
        } catch BatteryError.powerSourceUnavailable {
            print("Error: Power source information unavailable")
            return errorBatteryInfo
        } catch BatteryError.batteryInfoUnavailable(let reason) {
            print("Error: Battery information unavailable - \(reason)")
            return errorBatteryInfo
        } catch BatteryError.batteryParameterMissing(let parameter) {
            print("Error: Battery parameter missing - \(parameter)")
            return errorBatteryInfo
        } catch {
            print("Error: Unexpected error getting battery info - \(error.localizedDescription)")
            return errorBatteryInfo
        }
    }
}

struct BatteryInfo {
    var isPluggedIn: Bool
    var isCharging: Bool
    var currentCapacity: Float
    var maxCapacity: Float
    var isInLowPowerMode: Bool
    var timeToFullCharge: Int
}
