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

@MainActor
class VolumeManager: ObservableObject {
    static let shared = VolumeManager()
    
    @Published var volume: CGFloat = 0
    @Published var isMuted: Bool = false
    
    @Published var deviceIcon: String = "headphones"
    
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
        NotchManager.shared.showExtensionNotch(type: .volume)
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
            
            print("Output device:")
            print("  Name: \(deviceName)")
            print("  Modell: \(modelUID)")
            print("  Connection type: \(transportString)")
            
            
            // Get more information if audio device is Bluetooth
            if transportType == kAudioDeviceTransportTypeBluetooth || transportType == kAudioDeviceTransportTypeBluetoothLE {
                
                propertyAddress.mSelector = kAudioDevicePropertyDeviceUID
                propSize = UInt32(MemoryLayout<CFString?>.size)
                
                var uidRef: Unmanaged<CFString>?
                status = AudioObjectGetPropertyData(
                    defaultOutputDeviceID,
                    &propertyAddress,
                    0,
                    nil,
                    &propSize,
                    &uidRef
                )
                
                if status == noErr, let unwrappedRef = uidRef {
                    let uid = unwrappedRef.takeRetainedValue() as String
                    
                    if deviceName.contains("AirPods") || modelUID.contains("AirPods") || uid.contains("AirPods") {
                        self.deviceIcon = "airpods"
                        if deviceName.contains("Pro") || uid.contains("Pro") || modelUID.contains("Pro") {
                            self.deviceIcon = "airpods.pro"
                        } else if deviceName.contains("Max") || uid.contains("Max") || modelUID.contains("Max") {
                            self.deviceIcon = "airpods.max"
                        }
                    }
                }
            }
            
            if modelUID.contains("Codec Output") {
                self.deviceIcon = "headphones"
            }
        }
    }
    
    public func toggleMute() {
        if isMuted == true {
            setVolume(volBeforeMute)
            NotchManager.shared.showExtensionNotch(type: .volume)
        } else {
            volBeforeMute = volume
            setVolume(0)
            NotchManager.shared.showExtensionNotch(type: .volume)
        }
        
    }
    
    public func UpVolume() {
        let step: CGFloat = 1.0 / 32.0
        let newVolume = volume + step
        setVolume(newVolume)
        
    }
    
    public func DownVolume() {
        let step: CGFloat = 1.0 / 32.0
        let newVolume = volume - step
        setVolume(newVolume)
    }
    
    private func setVolume(_ volume: CGFloat) {
        let deviceID = defaultAudioDeviceID()
        guard deviceID != kAudioDeviceUnknown else { return }
        
        var newVolume = max(0.0, min(1.0, Float32(volume)))
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let volumeSize = UInt32(MemoryLayout<Float32>.size)
        let result = AudioObjectSetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            volumeSize,
            &newVolume
        )
        
        if result != noErr {
            print("Failed to set volume: \(result)")
        }
    }
}

