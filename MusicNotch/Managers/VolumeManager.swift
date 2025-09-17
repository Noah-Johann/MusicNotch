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

@MainActor
class VolumeManager: ObservableObject {
    static let shared = VolumeManager()
    
    @Published var volume: CGFloat = 0
    @Published var isMuted: Bool = false
    
    @Published var deviceIcon: String = "headphones"
    
    
    init() {
        setupObservers()
        setupVolumeObservers()
    }
    
    func setupObservers() {
        getAudioOutputDevice()
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        
        let callback: AudioObjectPropertyListenerProc = { (inObjectID, numberAddresses, addresses, clientData) -> OSStatus in
            let manager = Unmanaged<VolumeManager>.fromOpaque(clientData!).takeUnretainedValue()
            manager.getAudioOutputDevice()
            manager.setupVolumeObservers()
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
    
    func setupVolumeObservers() {
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
            return
        }
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let callback: AudioObjectPropertyListenerProc = { (inObjectID, numberAddresses, addresses, clientData) -> OSStatus in
            let manager = Unmanaged<VolumeManager>.fromOpaque(clientData!).takeUnretainedValue()
            manager.getSystemVolume()
            return noErr
        }
        
        let addStatus = AudioObjectAddPropertyListener(
            defaultOutputDeviceID,
            &address,
            callback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        
        if addStatus != noErr {
            print("Error adding volume listener")
        }
    }
    
    func getSystemVolume() {
        var defaultOutputDeviceID = AudioDeviceID(0)
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        // Get the default output device
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize,
            &defaultOutputDeviceID
        )
        
        guard status == noErr else {
            print("Error getting default output device")
            return
        }
        
        // Get the volume scalar (0.0 – 1.0)
        var volume = Float32(0)
        propertySize = UInt32(MemoryLayout<Float32>.size)
        address = AudioObjectPropertyAddress(
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
            
            if volume == 0 {
                self.isMuted = true
            }
            
            NotchManager.shared.showExtensionNotch(type: .volume)
        }
    }
    
    func getAudioOutputDevice() {
        // Get playback device
        var defaultOutputDeviceID: AudioDeviceID = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var propSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        var status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propSize,
            &defaultOutputDeviceID
        )
        
        
        guard status == noErr else {
            print("Error on getting output device: \(status)")
            return
        }
        
        guard defaultOutputDeviceID != 0 else {
            print("No device found")
            return
        }
        
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
            var transportString = "unknown"
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
}
