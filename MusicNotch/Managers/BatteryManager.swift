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

class BatteryManager: ObservableObject {
    static let shared = BatteryManager()
    
    @Published var currentCapacity: Double = 0
    
    @Published var batteryIconColor: Color = .white
    @Published var batteryIconName: String = "battery.100percent"
    
    private var previousBattery = BatteryManager.errorBatteryInfo
    
    private var batterySource: CFRunLoopSource?
    
    static let errorBatteryInfo = BatteryInfo(
        isPluggedIn: false,
        isCharging: false,
        currentCapacity: 1,
        maxCapacity: 100,
        isInLowPowerMode: false,
        timeToFullCharge: 1,
        showLowPower: false
    )
    
    enum BatteryError: Error {
        case powerSourceUnavailable
        case batteryInfoUnavailable(String)
        case batteryParameterMissing(String)
    }
    
    init() {
        previousBattery = getBatteryInfo()
        
        setupObservers()
        startMonitoring()
    }
    
    deinit {
        if let source = batterySource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
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
            Task { @MainActor in
                manager.updateBatteryInfo()
            }
        }, Unmanaged.passUnretained(self).toOpaque())?.takeRetainedValue() else {
            return
        }
        batterySource = powerSource
        CFRunLoopAddSource(CFRunLoopGetCurrent(), powerSource, .defaultMode)
    }
    
    @objc private func lowPowerModeChanged() {
        print("low power mode notification")
        Task { @MainActor in
            updateBatteryInfo()
        }
    }
    
    @MainActor
    func updateBatteryInfo() {
        guard Defaults[.batteryExtension] == true else { return }
        
        let info = getBatteryInfo()
        
        
        self.currentCapacity = Double(info.currentCapacity)
        
        
        if info.isPluggedIn == true {
            self.batteryIconName = "battery.100percent.bolt"
        } else {
            self.batteryIconName = "battery.100percent"
        }
        
        if info.showLowPower == true {
            self.batteryIconColor = .red
        } else if info.isInLowPowerMode == true {
            self.batteryIconColor = .yellow
        } else if info.isPluggedIn == true {
            self.batteryIconColor = .green
        } else {
            self.batteryIconColor = .white
        }
        
        
        if previousBattery.isInLowPowerMode != info.isInLowPowerMode {
            Task { @MainActor in
                NotchManager.shared.showExtensionNotch(type: .battery)
            }
            
        } else if previousBattery.isPluggedIn != info.isPluggedIn {
            Task { @MainActor in
                NotchManager.shared.showExtensionNotch(type: .battery)
            }
            
        } else if previousBattery.showLowPower != info.showLowPower {
            guard info.isPluggedIn == false else { return }
            guard info.showLowPower == true else { return }
            
            Task { @MainActor in
                NotchManager.shared.showExtensionNotch(type: .battery)
            }
        }
        previousBattery = info
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
            guard let currentCapacity = description[kIOPSCurrentCapacityKey] as? Int else {
                throw BatteryError.batteryParameterMissing("Current capacity")
            }
            
            guard let maxCapacity = description[kIOPSMaxCapacityKey] as? Int else {
                throw BatteryError.batteryParameterMissing("Max capacity")
            }
            
            guard let isCharging = description[kIOPSIsChargingKey] as? Bool else {
                throw BatteryError.batteryParameterMissing("Charging state")
            }
            
            guard let powerSource = description[kIOPSPowerSourceStateKey] as? String else {
                throw BatteryError.batteryParameterMissing("Power source state")
            }
            
            let showLowPower: Bool
            if currentCapacity == 10 {
                showLowPower = true
            } else {
                showLowPower = false
            }
            
            // Create battery info with the extracted parameters
            var batteryInfo = BatteryInfo(
                isPluggedIn: powerSource == kIOPSACPowerValue,
                isCharging: isCharging,
                currentCapacity: Float(currentCapacity),
                maxCapacity: Float(maxCapacity),
                isInLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
                timeToFullCharge: 0,
                showLowPower: showLowPower
            )
            
            // Optional parameters
            if let timeToFullCharge = description[kIOPSTimeToFullChargeKey] as? Int {
                batteryInfo.timeToFullCharge = timeToFullCharge
            }
            
            return batteryInfo
            
        } catch BatteryError.powerSourceUnavailable {
            print("Error: Power source information unavailable")
            return BatteryManager.errorBatteryInfo
        } catch BatteryError.batteryInfoUnavailable(let reason) {
            print("Error: Battery information unavailable - \(reason)")
            return BatteryManager.errorBatteryInfo
        } catch BatteryError.batteryParameterMissing(let parameter) {
            print("Error: Battery parameter missing - \(parameter)")
            return BatteryManager.errorBatteryInfo
        } catch {
            print("Error: Unexpected error getting battery info - \(error.localizedDescription)")
            return BatteryManager.errorBatteryInfo
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
    var showLowPower: Bool
}
