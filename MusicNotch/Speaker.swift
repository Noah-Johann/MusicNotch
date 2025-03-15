//
//  Speaker.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation
import CoreAudio

func getAudioOutputDevices() {
    var propertySize: UInt32 = 0
    
    // Größe des Property Arrays abfragen
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    // Größe des Geräte-Arrays ermitteln
    var status = AudioObjectGetPropertyDataSize(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &propertySize
    )
    
    guard status == noErr else {
        print("Fehler beim Ermitteln der Gerätegröße: \(status)")
        return
    }
    
    // Speicher für Geräte reservieren
    let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
    var audioDevices = [AudioDeviceID](repeating: 0, count: deviceCount)
    
    // Geräte abrufen
    status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &propertySize,
        &audioDevices
    )
    
    guard status == noErr else {
        print("Fehler beim Abrufen der Geräte: \(status)")
        return
    }
    
    // Aktuelles Standardausgabegerät ermitteln
    var defaultOutputDeviceID: AudioDeviceID = 0
    propertyAddress.mSelector = kAudioHardwarePropertyDefaultOutputDevice
    var propSize = UInt32(MemoryLayout<AudioDeviceID>.size)
    
    status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &propSize,
        &defaultOutputDeviceID
    )
    
    guard status == noErr else {
        print("Fehler beim Ermitteln des Standardausgabegeräts: \(status)")
        return
    }
    
    // Ausgabegeräte filtern und analysieren
    for deviceID in audioDevices {
        // Prüfen, ob das Gerät Ausgabe unterstützt
        propertyAddress.mSelector = kAudioDevicePropertyStreamConfiguration
        propertyAddress.mScope = kAudioDevicePropertyScopeOutput
        
        var streamConfigSize: UInt32 = 0
        status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &streamConfigSize
        )
        
        guard status == noErr, streamConfigSize > 0 else {
            continue
        }
        
        // Gerätename abrufen
        var deviceName = "Unbekannt"
        propertyAddress.mSelector = kAudioDevicePropertyDeviceNameCFString
        propertyAddress.mScope = kAudioObjectPropertyScopeGlobal
        propSize = UInt32(MemoryLayout<CFString?>.size)
        
        // Temporären Speicherbereich für den Namen erstellen
        var nameRef: Unmanaged<CFString>?
        status = AudioObjectGetPropertyData(
            deviceID,
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
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propSize,
            &modelRef
        )
        
        if status == noErr, let unwrappedRef = modelRef {
            modelUID = unwrappedRef.takeRetainedValue() as String
        }
        
        // Herstellername abrufen
        var manufacturer = "Unbekannt"
        propertyAddress.mSelector = kAudioDevicePropertyDeviceManufacturerCFString
        propSize = UInt32(MemoryLayout<CFString?>.size)
        
        var manufacturerRef: Unmanaged<CFString>?
        status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propSize,
            &manufacturerRef
        )
        
        if status == noErr, let unwrappedRef = manufacturerRef {
            manufacturer = unwrappedRef.takeRetainedValue() as String
        }
        
        // Transporttyp abrufen (Bluetooth, USB, etc.)
        var transportType: UInt32 = 0
        propertyAddress.mSelector = kAudioDevicePropertyTransportType
        propSize = UInt32(MemoryLayout<UInt32>.size)
        
        _ = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propSize,
            &transportType
        )
        
        // Prüfen, ob das Gerät aktuell verwendet wird (läuft)
        propertyAddress.mSelector = kAudioDevicePropertyDeviceIsRunning
        var isRunning: UInt32 = 0
        propSize = UInt32(MemoryLayout<UInt32>.size)
        
        _ = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &propSize,
            &isRunning
        )
        
        // Ergebnisse zusammenstellen und ausgeben
        let active = isRunning > 0
        let isDefault = deviceID == defaultOutputDeviceID
        
        var transportString = "Unbekannt"
        switch transportType {
        case kAudioDeviceTransportTypeBuiltIn:
            transportString = "Eingebaut"
        case kAudioDeviceTransportTypeBluetooth, kAudioDeviceTransportTypeBluetoothLE:
            transportString = "Bluetooth"
        case kAudioDeviceTransportTypeUSB:
            transportString = "USB"
        case kAudioDeviceTransportTypeAirPlay:
            transportString = "AirPlay"
        case kAudioDeviceTransportTypeVirtual:
            transportString = "Virtuell"
        case kAudioDeviceTransportTypeAVB:
            transportString = "AVB"
        case kAudioDeviceTransportTypeThunderbolt:
            transportString = "Thunderbolt"
        case kAudioDeviceTransportTypeHDMI:
            transportString = "HDMI"
        case kAudioDeviceTransportTypeDisplayPort:
            transportString = "DisplayPort"
        default:
            transportString = "Andere (\(transportType))"
        }
        
        print("Gerät: \(deviceName)")
        print("  Modell: \(modelUID)")
        print("  Hersteller: \(manufacturer)")
        print("  Verbindungstyp: \(transportString)")
        print("  Aktiv: \(active)")
        print("  Standard-Ausgabegerät: \(isDefault)")
        print("")
    }
}

