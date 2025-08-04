//
//  BatteryManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import Foundation
import IOKit.ps
import Combine

class BatteryManager {
    static let shared = BatteryManager()
    
    @Published var batteryPercentage: Double = 0.0
    @Published var isCharging: Bool = false
    @Published var currentCapacity: Int = 0
    @Published var maxCapacity: Int = 0
    @Published var cycleCount: Int = 0
    @Published var health: String = "Unknown"
    @Published var isLowPowerMode: Bool = false
    
    private var powerObserver: NSObjectProtocol?
    private var lowPowerModeObserver: NSObjectProtocol?
    private var timer: Timer?
    
    private var runLoopSource: Unmanaged<CFRunLoopSource>?
    private var powerSourceMonitor: PowerSourceMonitor?
    
    init() {
        startPowerObservers()
    }
    
    deinit {
        stopPowerObservers()
    }
    
    private func updateBatteryInfo() {
        guard let info = getBatteryInfo() else { return }
        
        DispatchQueue.main.async {
            self.batteryPercentage = info.batteryPercentage
            self.isCharging = info.isCharging
            self.currentCapacity = info.currentCapacity
            self.maxCapacity = info.maxCapacity
            self.cycleCount = info.cycleCount
            self.health = info.health
            self.isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
        
        Task { @MainActor in
            NotchManager.shared.showExtensionNotch(type: .battery)
        }
    }
    
    private func startPowerObservers() {
        // Observe Low Power Mode changes
        lowPowerModeObserver = NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBatteryInfo()
            print("low power noti")
        }
        
        powerSourceMonitor = PowerSourceMonitor()

        NotificationCenter.default.addObserver(
            forName: .powerSourceDidChange,
            object: nil,
            queue: .main
        ) { notification in
            if let powerSource = notification.object as? String {
                if powerSource == "AC Power" {
                    self.isCharging = true
                }
            }
            print("new noti")
            self.updateBatteryInfo()
        }
    }

    
    @objc private func batteryStateChanged() {
        updateBatteryInfo()
        print("battery state changed")
    }
    
    private func stopPowerObservers() {
        if let observer = powerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = lowPowerModeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getBatteryInfo() -> (batteryPercentage: Double, isCharging: Bool, currentCapacity: Int, maxCapacity: Int, cycleCount: Int, health: String)? {
        print("getBatteryInfo")
        guard let powerSourcesInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let powerSourcesList = IOPSCopyPowerSourcesList(powerSourcesInfo)?.takeRetainedValue() as? [CFTypeRef] else {
            return nil
        }
        
        for powerSource in powerSourcesList {
            guard let dict = IOPSGetPowerSourceDescription(powerSourcesInfo, powerSource)?.takeUnretainedValue() as? [String: Any],
                  let transportType = dict[kIOPSTransportTypeKey] as? String,
                  transportType == kIOPSInternalType else {
                continue
            }
            
            let currentCapacity = dict[kIOPSCurrentCapacityKey] as? Int ?? 0
            let maxCapacity = dict[kIOPSMaxCapacityKey] as? Int ?? 0
            let isCharging = dict[kIOPSIsChargingKey] as? Bool ?? false
            let cycleCount = dict["CycleCount"] as? Int ?? 0
            let health = dict["BatteryHealth"] as? String ?? "Unknown"
            
            let percentage = maxCapacity > 0 ? Double(currentCapacity) / Double(maxCapacity) * 100 : 0.0
            
            return (percentage, isCharging, currentCapacity, maxCapacity, cycleCount, health)
        }
        
        return nil
    }
}

class PowerSourceMonitor {
    private var runLoopSource: Unmanaged<CFRunLoopSource>?
    private var lastPowerSource: String?

    init() {
        let callback: IOPowerSourceCallbackType = { context in
            let psInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
            let psList = IOPSCopyPowerSourcesList(psInfo).takeRetainedValue() as Array

            var currentPowerSource: String?

            for ps in psList {
                if let description = IOPSGetPowerSourceDescription(psInfo, ps).takeUnretainedValue() as? [String: Any],
                   let powerSource = description[kIOPSPowerSourceStateKey] as? String {
                    currentPowerSource = powerSource
                    break  // Only check the first valid power source
                }
            }

            if let powerSource = currentPowerSource {
                let monitor = Unmanaged<PowerSourceMonitor>.fromOpaque(context!).takeUnretainedValue()
                if monitor.lastPowerSource != powerSource {
                    monitor.lastPowerSource = powerSource
                    print("Power source changed: \(powerSource)")
                    NotificationCenter.default.post(name: .powerSourceDidChange, object: powerSource)
                }
            }
        }

        runLoopSource = IOPSNotificationCreateRunLoopSource(callback, Unmanaged.passUnretained(self).toOpaque())
        if let source = runLoopSource?.takeRetainedValue() {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }

    deinit {
        if let source = runLoopSource?.takeUnretainedValue() {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }
}

extension Notification.Name {
    static let powerSourceDidChange = Notification.Name("PowerSourceDidChangeNotification")
}
