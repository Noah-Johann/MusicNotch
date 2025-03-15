//
//  Speaker.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import IOKit

func getModelIdentifier() -> String {
    var modelIdentifier: String = "Unbekannt"

    // Zugriff auf das passende Systemservice
    guard let matchingDict = IOServiceMatching("IOPlatformExpertDevice") else {
        print("Fehler: Kein passendes Systemdienst gefunden.")
        return modelIdentifier
    }

    var iterator: io_iterator_t = 0
    let kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iterator)

    // Überprüfen, ob die Suche erfolgreich war
    if kernResult != KERN_SUCCESS {
        print("Fehler bei IOServiceGetMatchingServices: \(kernResult)")
        return modelIdentifier
    }

    // Überprüfen, ob das Plattformdienstobjekt gefunden wurde
    let platformService = IOIteratorNext(iterator)
    if platformService == 0 {
        print("Fehler: Plattformdienst nicht gefunden.")
        IOObjectRelease(iterator)
        return modelIdentifier
    }

    // Abrufen des Modellbezeichners
    let modelKey = "model" as CFString
    if let model = IORegistryEntryCreateCFProperty(platformService, modelKey, kCFAllocatorDefault, 0) {
        modelIdentifier = model.takeUnretainedValue() as! String
        print("Modellbezeichner abgerufen: \(modelIdentifier)")  // Ausgabe für Debugging
    } else {
        print("Fehler: Modellbezeichner konnte nicht abgerufen werden.")
    }

    // Freigabe der Ressourcen
    IOObjectRelease(platformService)
    IOObjectRelease(iterator)

    return modelIdentifier
}
