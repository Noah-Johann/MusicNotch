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

@Observable
class VolumeManager {
    static let shared = VolumeManager()
    
    var volume: CGFloat = 0
    var isMuted: Bool = false
    
    var deviceName: String = ""
    var deviceIcon: String = "headphones"
    var deviceID: String = ""
    var deviceBattery: CGFloat = 100
    var deviceVideo: String = "AirPodsPro2"
    
    private var volBeforeMute: CGFloat = 0
    private var currentDeviceID: AudioDeviceID = kAudioDeviceUnknown
    
    init() {
        setupDeviceChangeObserver()
        handleDeviceChange()
    }
    
    private func getAudioDeviceID() -> AudioDeviceID {
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
    
    func setupDeviceChangeObserver() {
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

    private func setupDeviceVolumeObservers(for deviceID: AudioDeviceID) {
        var volAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        let volCallback: AudioObjectPropertyListenerProc = { (_, _, _, clientData) -> OSStatus in
            let manager = Unmanaged<VolumeManager>.fromOpaque(clientData!).takeUnretainedValue()
            manager.updateVolume()
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
            manager.updateVolume()
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
    
    
    func updateVolume() {
        Task { @MainActor in
            let prevVolume = volume
            let prevMute = isMuted
            
            currentDeviceID = getAudioDeviceID()
            guard currentDeviceID != kAudioDeviceUnknown else { return }
            
            volume = getVolume(device: currentDeviceID)
            isMuted = getMuteStatus(device: currentDeviceID)
            
            if prevVolume != volume || prevMute != isMuted {
                showUpdate()
            }
        }
    }
    
    
    private func getVolume(device: AudioDeviceID) -> CGFloat {
        var usedVolume: Float32? = nil
        func channelVolume(_ ch: UInt32) -> Float32? {
            var addr = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: ch
            )
            guard AudioObjectHasProperty(device, &addr) else { return nil }
            var vol = Float32(0)
            var size = UInt32(MemoryLayout<Float32>.size)
            let status = AudioObjectGetPropertyData(device, &addr, 0, nil, &size, &vol)
            return status == noErr ? vol : nil
        }

        let left = channelVolume(1)
        let right = channelVolume(2)
        if let l = left, let r = right {
            usedVolume = (l + r) / 2
        } else if let single = left ?? right {
            usedVolume = single
        }

        if usedVolume == nil {
            var addr = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: kAudioObjectPropertyElementMain
            )
            if AudioObjectHasProperty(device, &addr) {
                var vol = Float32(0)
                var size = UInt32(MemoryLayout<Float32>.size)
                let status = AudioObjectGetPropertyData(device, &addr, 0, nil, &size, &vol)
                if status == noErr {
                    usedVolume = vol
                }
            }
        }

        if let vol = usedVolume {
            return CGFloat(vol)
        }
        
        return 0
    }
    
    private func getMuteStatus(device: AudioDeviceID) -> Bool {
        var mute: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        let status = AudioObjectGetPropertyData(device, &address, 0, nil, &propertySize, &mute)
        
        guard status == noErr else { return false }

        return (mute != 0)
    }
    
    @MainActor private func showUpdate() {
        if Defaults[.hudExtension] {
            print("showhud")
            NotchManager.shared.showExtensionNotch(type: .volume, duration: Defaults[.displayDuration])
        }
    }

    private func handleDeviceChange() {
        Task {
            let newDevice = getAudioDeviceID()
            guard newDevice != kAudioDeviceUnknown else { return }
            
            if currentDeviceID != kAudioDeviceUnknown && currentDeviceID != newDevice {
                teardownPerDeviceObservers(for: currentDeviceID)
            }
            currentDeviceID = newDevice
            
            getAudioOutputDevice(device: newDevice)
            
            volume = getVolume(device: newDevice)
            isMuted = getMuteStatus(device: newDevice)
            
            try await Task.sleep(for: .milliseconds(400))

            setupDeviceVolumeObservers(for: newDevice)
        }
    }
    
    func getAudioOutputDevice(device: AudioDeviceID) {
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
            device,
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
            device,
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
            device,
            &propertyAddress,
            0,
            nil,
            &propSize,
            &transportType
        )
        Task { @MainActor in
            var transportString: String = "unknown"
            switch transportType {
            case kAudioDeviceTransportTypeBuiltIn:
                transportString = "Build in"
                self.deviceIcon = "macbook.gen2"
            case kAudioDeviceTransportTypeBluetooth, kAudioDeviceTransportTypeBluetoothLE:
                transportString = "Bluetooth"
                self.deviceIcon = "earbuds.stemless"
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
            }

        }
    }
    
    @MainActor private func getBluetoothModel (name: String) {
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
                                print("self \(self.deviceIcon)")
                                print(deviceName)
                                if deviceName == name,
                                   let deviceDict = deviceData as? [String: Any] {
                                    
                                    self.deviceID = deviceDict["device_productID"] as? String ?? ""
                                    let vendorID = deviceDict["device_vendorID"] as? String ?? nil

                                    
                                    if let batteryString = deviceDict["device_batteryLevel"] as? String {
                                        let battery = Int(batteryString.filter { $0.isNumber }) ?? nil
                                        self.deviceBattery = CGFloat(battery!)
                                    }

                                    if let batteryLeftString = deviceDict["device_batteryLevelLeft"] as? String, let batteryRightString = deviceDict["device_batteryLevelRight"] as? String {
                                        let batteryLeft = Int(batteryLeftString.filter { $0.isNumber }) ?? 100
                                        let batteryRight = Int(batteryRightString.filter { $0.isNumber }) ?? 100
                                        self.deviceBattery = CGFloat(min(batteryLeft, batteryRight))
                                    }
                                    
                                    if vendorID == "0x004C" {
                                        getAirPodsInfo(device: deviceID)
                                        
                                        if Defaults[.bluetoothRecognition] {
                                            NotchManager.shared.showExtensionNotch(type: .bluetooth, duration: Defaults[.displayDuration])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func getAirPodsInfo(device: String) {
        switch device {
        case "0x2027":
            self.deviceVideo = "AirPodsPro3"
            self.deviceIcon = "airpods.pro"
        case "0x2024", "0x2014":
            self.deviceVideo = "AirPodsPro2"
            self.deviceIcon = "airpods.pro"
        case "0x200E":
            self.deviceVideo = "AirPodsPro1"
            self.deviceIcon = "airpods.pro"
        case "0x2019":
            self.deviceVideo = "AirPods4"
            self.deviceIcon = "airpods.gen4"
        case "0x2013":
            self.deviceVideo = "AirPods3"
            self.deviceIcon = "airpods.gen3"
        case "0x200F", "0x2002":
            self.deviceVideo = "AirPods1"
            self.deviceIcon = "airpods"
        case "0x201F":
            self.deviceVideo = "AirPodsMax2"
            self.deviceIcon = "airpods.max"
        case "0x200A":
            self.deviceVideo = "AirPodsMax1"
            self.deviceIcon = "airpods.max"
        default:
            self.deviceVideo = "AirPodsPro2"
            self.deviceIcon = "airpods.pro"
        }
        
    }
}

