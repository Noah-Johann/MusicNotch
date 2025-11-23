//
//  VolumeManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 12.09.25.
//

import Foundation
import CoreAudio
import AppKit
import Combine
import SwiftUI
import Defaults

@MainActor
class VolumeManager: ObservableObject {
    static let shared = VolumeManager()
    
    @Published var volume: CGFloat = 0
    @Published var isMuted: Bool = false
    
    @Published var deviceName: String = ""
    @Published var deviceIcon: String = "headphones"
    @Published var deviceID: String = ""
    @Published var deviceBattery: Int = 100
    
    
    private var volBeforeMute: CGFloat = 0
    private var currentDeviceID: AudioDeviceID = kAudioDeviceUnknown
    
    init() {
        setupDeviceObserver()
        handleDeviceChange()
    }
    
    private func defaultAudioDeviceID() -> AudioDeviceID {
        var defaultOutputDeviceID = AudioDeviceID(0)
         var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
         var defaultAddress = AudioObjectPropertyAddress(
             mSelector: kAudioHardwarePropertyDefaultOutputDevice,
             mScope: kAudioObjectPropertyScopeGlobal,
             mElement: kAudioObjectPropertyElementMain
         )
         
         let status = AudioObjectGetPropertyData(
             AudioObjectID(kAudioObjectSystemObject),
             &defaultAddress,
             0,
             nil,
             &propertySize,
             &defaultOutputDeviceID
         )
         
         guard status == noErr else {
             print("Error getting default output device for observer")
             return kAudioDeviceUnknown
         }
        
        return defaultOutputDeviceID
    }
    
    func setupDeviceObserver() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        
        let callback: AudioObjectPropertyListenerProc = { (inObjectID, numberAddresses, addresses, clientData) -> OSStatus in
            let manager = Unmanaged<VolumeManager>.fromOpaque(clientData!).takeUnretainedValue()
            manager.handleDeviceChange()
            return noErr
        }
        
        let status = AudioObjectAddPropertyListener(
            systemObjectID,
            &address,
            callback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        if status != noErr {
            print("Error setting up audio device observer")
        }
    }

    private func setupPerDeviceObservers(for deviceID: AudioDeviceID) {
        var volAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        let volCallback: AudioObjectPropertyListenerProc = { (_, _, _, clientData) -> OSStatus in
            let manager = Unmanaged<VolumeManager>.fromOpaque(clientData!).takeUnretainedValue()
            manager.getSystemVolume()
            manager.getMuteStatus()
            manager.showUpdate()
            return noErr
        }
        _ = AudioObjectAddPropertyListener(
            deviceID,
            &volAddress,
            volCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )

        var muteAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        let muteCallback: AudioObjectPropertyListenerProc = { (_, _, _, clientData) -> OSStatus in
            let manager = Unmanaged<VolumeManager>.fromOpaque(clientData!).takeUnretainedValue()
            manager.getMuteStatus()
            manager.getSystemVolume()
            manager.showUpdate()
            return noErr
        }
        _ = AudioObjectAddPropertyListener(
            deviceID,
            &muteAddress,
            muteCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )

    }

    private func teardownPerDeviceObservers(for deviceID: AudioDeviceID) {

        var volAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        _ = AudioObjectRemovePropertyListener(
            deviceID,
            &volAddress,
            { (_, _, _, _) -> OSStatus in return noErr },
            nil
        )

        var muteAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        _ = AudioObjectRemovePropertyListener(
            deviceID,
            &muteAddress,
            { (_, _, _, _) -> OSStatus in return noErr },
            nil
        )
    }
    
    func getSystemVolume() {
        let defaultOutputDeviceID = defaultAudioDeviceID()
        guard defaultOutputDeviceID != kAudioDeviceUnknown else {
            print("Error getting default output device")
            return
        }
        
        var volume = Float32(0)
        var propertySize = UInt32(MemoryLayout<Float32>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let volStatus = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &address,
            0,
            nil,
            &propertySize,
            &volume
        )
        
        guard volStatus == noErr else {
            print("Error getting device volume")
            return
        }
        
        DispatchQueue.main.async {
            self.volume = CGFloat(volume)
            self.isMuted = (volume == 0) || self.isMuted
        }
    }
    
    private func getMuteStatus() {
        let deviceID = defaultAudioDeviceID()
        guard deviceID != kAudioDeviceUnknown else { return }

        var mute: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &propertySize,
            &mute
        )
        guard status == noErr else { return }
        DispatchQueue.main.async {
            self.isMuted = (mute != 0)
        }
    }
    
    private func showUpdate() {
        if Defaults[.hudExtension] {
            NotchManager.shared.showExtensionNotch(type: .volume)
        }
    }

    private func handleDeviceChange() {
        let newDevice = defaultAudioDeviceID()
        guard newDevice != kAudioDeviceUnknown else { return }

        if currentDeviceID != kAudioDeviceUnknown && currentDeviceID != newDevice {
            teardownPerDeviceObservers(for: currentDeviceID)
        }
        currentDeviceID = newDevice

        // Update device info
        getAudioOutputDevice()
        // Register per-device observers
        setupPerDeviceObservers(for: newDevice)
        // Refresh current values
        getSystemVolume()
        getMuteStatus()
    }
    
    func getAudioOutputDevice() {
        // Get playback device
        let defaultOutputDeviceID = defaultAudioDeviceID()
        guard defaultOutputDeviceID != kAudioDeviceUnknown else {
            print("No device found")
            return
        }
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var propSize: UInt32
        var status: OSStatus
        
        // Get device name
        var deviceName = "Unknown"
        propertyAddress.mSelector = kAudioDevicePropertyDeviceNameCFString
        propertyAddress.mScope = kAudioObjectPropertyScopeGlobal
        propSize = UInt32(MemoryLayout<CFString?>.size)
        
        var nameRef: Unmanaged<CFString>?
        status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &propertyAddress,
            0,
            nil,
            &propSize,
            &nameRef
        )
        
        if status == noErr, let unwrappedRef = nameRef {
            deviceName = unwrappedRef.takeRetainedValue() as String
        }
        
        // Get UUID
        var modelUID = "empty"
        propertyAddress.mSelector = kAudioDevicePropertyModelUID
        propSize = UInt32(MemoryLayout<CFString?>.size)
        
        var modelRef: Unmanaged<CFString>?
        status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &propertyAddress,
            0,
            nil,
            &propSize,
            &modelRef
        )
        
        if status == noErr, let unwrappedRef = modelRef {
            modelUID = unwrappedRef.takeRetainedValue() as String
        }
        
        // Get connection type
        var transportType: UInt32 = 0
        propertyAddress.mSelector = kAudioDevicePropertyTransportType
        propSize = UInt32(MemoryLayout<UInt32>.size)
        
        _ = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &propertyAddress,
            0,
            nil,
            &propSize,
            &transportType
        )
        DispatchQueue.main.async {
            var transportString: String = "unknown"
            switch transportType {
            case kAudioDeviceTransportTypeBuiltIn:
                transportString = "Build in"
                self.deviceIcon = "macbook.gen2"
            case kAudioDeviceTransportTypeBluetooth, kAudioDeviceTransportTypeBluetoothLE:
                transportString = "Bluetooth"
            case kAudioDeviceTransportTypeUSB:
                transportString = "USB"
            case kAudioDeviceTransportTypeAirPlay:
                transportString = "AirPlay"
            case kAudioDeviceTransportTypeVirtual:
                transportString = "Virtuell"
            case kAudioDeviceTransportTypeDisplayPort:
                transportString = "DisplayPort"
                self.deviceIcon = "display"
            case kAudioDeviceTransportTypeHDMI:
                transportString = "HDMI"
                self.deviceIcon = "display"
            default:
                transportString = "Other"
                self.deviceIcon = "headphones"
            }
            
            if modelUID.contains("Codec Output") {
                self.deviceIcon = "headphones"
            }
            
            print("Output device:")
            print("  Name: \(deviceName)")
            print("  Modell: \(modelUID)")
            print("  Connection type: \(transportString)")
            
            
            if transportType == kAudioDeviceTransportTypeBluetooth || transportType == kAudioDeviceTransportTypeBluetoothLE {
                self.getBluetoothModel(name: deviceName)
//                propertyAddress.mSelector = kAudioDevicePropertyDeviceUID
//                propSize = UInt32(MemoryLayout<CFString?>.size)
//                
//                var uidRef: Unmanaged<CFString>?
//                status = AudioObjectGetPropertyData(
//                    defaultOutputDeviceID,
//                    &propertyAddress,
//                    0,
//                    nil,
//                    &propSize,
//                    &uidRef
//                )
//                
//                if status == noErr, let unwrappedRef = uidRef {
//                    let uid = unwrappedRef.takeRetainedValue() as String
//                    
//                    if deviceName.contains("AirPods") || modelUID.contains("AirPods") || uid.contains("AirPods") {
//                        self.deviceIcon = "airpods"
//                        if deviceName.contains("Pro") || uid.contains("Pro") || modelUID.contains("Pro") {
//                            self.deviceIcon = "airpods.pro"
//                        } else if deviceName.contains("Max") || uid.contains("Max") || modelUID.contains("Max") {
//                            self.deviceIcon = "airpods.max"
//                        }
//                    }
//                }
            }

        }
    }
    
    private func getBluetoothModel (name: String) {
        let task = Process()
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPBluetoothDataType", "-json"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                guard let btArray = root["SPBluetoothDataType"] as? [[String: Any]] else { return }
                
                for entry in btArray {
                    if let devices = entry["device_connected"] as? [[String: Any]] {
                        for deviceObj in devices {
                            for (deviceName, deviceData) in deviceObj {
                                if deviceName.contains("AirPods"),
                                   let deviceDict = deviceData as? [String: Any] {
                                    
                                    self.deviceID = deviceDict["device_productID"] as? String ?? ""
                                    
//                                    var battery: Int = 100
//                                    for items in deviceDict {
//                                        if items.key.contains("battery") {
//                                            var keyBattery = items.value as? Int ?? 100
//                                            if keyBattery < battery {
//                                                battery = keyBattery
//                                            }
//                                        }
//                                    }
                                    let batteryString = deviceDict["device_batteryLevel"] as? String
                                    
                                    if batteryString != nil {
                                        let battery = Int(batteryString!.filter { $0.isNumber }) ?? nil
                                        self.deviceBattery = battery!
                                    }
                                    
                                    let batteryLeftString = deviceDict["device_batteryLevelLeft"] as? String ?? nil
                                    let batteryRightString = deviceDict["device_batteryLevelRight"] as? String ?? nil
                                    
                                    guard batteryRightString != nil else { return }
                                    guard batteryLeftString != nil else { return }
                                    
                                    let batteryLeft = Int(batteryLeftString!.filter { $0.isNumber }) ?? 100
                                    let batteryRight = Int(batteryRightString!.filter { $0.isNumber }) ?? 100
                                    
                                    if batteryLeft < batteryRight {
                                        self.deviceBattery = batteryLeft
                                    } else if batteryLeft > batteryRight {
                                        self.deviceBattery = batteryRight
                                    }
                                                                        
                                    print(deviceID)
                                    print(deviceBattery)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        print("newdevice")
    }
}

