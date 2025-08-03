//
//  SpeakerIcon.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation
import CoreAudio


class AudioDeviceManager {
    static let shared = AudioDeviceManager()
    
    @Published var deviceIcon: String = "headphones"
    
    init() {
        registerForAudioDeviceChanges()
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
        
        var transportString = "unknown"
        switch transportType {
        case kAudioDeviceTransportTypeBuiltIn:
            transportString = "Build in"
            deviceIcon = "macbook.gen2"
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
            deviceIcon = "display"
        case kAudioDeviceTransportTypeHDMI:
            transportString = "HDMI"
            deviceIcon = "display"
        default:
            transportString = "Other"
            deviceIcon = "headphones"
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
                    //print("  Device recognized as AirPods")
                    deviceIcon = "airpods"
                    if deviceName.contains("Pro") || uid.contains("Pro") || modelUID.contains("Pro") {
                        //print("  type: Pro")
                        deviceIcon = "airpods.pro"
                    } else if deviceName.contains("Max") || uid.contains("Max") || modelUID.contains("Max") {
                        //print("  type: Max")
                        deviceIcon = "airpods.max"
                    }
                }
            }
        }
        
        if deviceName.contains("Externe Kopfhörer") || modelUID.contains("Codec Output") {
            deviceIcon = "headphones"
        }
    }
    
    
    
    func registerForAudioDeviceChanges() {
        getAudioOutputDevice()
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        
        let callback: AudioObjectPropertyListenerProc = { (inObjectID, numberAddresses, addresses, clientData) -> OSStatus in
            let manager = Unmanaged<AudioDeviceManager>.fromOpaque(clientData!).takeUnretainedValue()
            manager.getAudioOutputDevice()
            return noErr
        }
        
        let status = AudioObjectAddPropertyListener(
            systemObjectID,
            &address,
            callback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        
        if status == noErr {
            //print("Listener für output device changes registert")
        }
    }
}
