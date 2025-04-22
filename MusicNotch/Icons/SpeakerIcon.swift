//
//  SpeakerIcon.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//
import Foundation
import CoreAudio

public var deviceIcon: String = "headphones"

func getAudioOutputDevice() {
    // Aktuelles Standardausgabegerät ermitteln
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
    
    // Gerätename abrufen
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
    
    // Modell-UID abrufen
    var modelUID = "Nicht verfügbar"
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
    
    // Transporttyp abrufen (Bluetooth, USB, etc.)
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
    
    var transportString = "Unbekannt"
    switch transportType {
    case kAudioDeviceTransportTypeBuiltIn:
        transportString = "Eingebaut"
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
        transportString = "Andere"
        deviceIcon = "headphones"
    }
    
    print("Output device:")
    print("  Name: \(deviceName)")
    print("  Modell: \(modelUID)")
    print("  Connection type: \(transportString)")
    
    // Für bestimmte Gerätetypen zusätzliche Informationen abrufen
    if transportType == kAudioDeviceTransportTypeBluetooth || transportType == kAudioDeviceTransportTypeBluetoothLE {
        // Spezifische Bluetooth-Geräte-Eigenschaften abrufen
        // Diese können je nach Gerätetyp variieren
        var bluetoothDeviceInfo = "No additional information"
        
        // Bei Bluetooth-Geräten können weitere Eigenschaften interessant sein
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
            bluetoothDeviceInfo = "Gerät-UID: \(uid)"
            
            // AirPods oder ähnliche Geräte können oft anhand der UID oder des ModelUID erkannt werden
            if deviceName.contains("AirPods") || modelUID.contains("AirPods") || uid.contains("AirPods") {
                print("  Device recognized as AirPods")
                deviceIcon = "airpods"
                if deviceName.contains("Pro") || uid.contains("Pro") || modelUID.contains("Pro") {
                    print("  type: Pro")
                    deviceIcon = "airpods.pro"
                } else if deviceName.contains("Max") || uid.contains("Max") || modelUID.contains("Max") {
                    print("  type: Max")
                    deviceIcon = "airpods.max"
                }
            }
        }
    }
        
    if deviceName.contains("Externe Kopfhörer") || modelUID.contains("Codec Output") {
        print("Headphones")
        deviceIcon = "headphones"
    }
}



func registerForAudioDeviceChanges() {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
    
    let callback: AudioObjectPropertyListenerProc = { _, _, _, _ in
        print("Output device has changed")
        getAudioOutputDevice()
        return noErr
    }
    
    let status = AudioObjectAddPropertyListener(
        systemObjectID,
        &address,
        callback,
        nil
    )
    
    if status == noErr {
        print("Listener für output device changes registert")
    }
}
