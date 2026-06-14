//
//  BetterDisplayManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 02.03.26.
//

import AppKit
import Defaults

@Observable
class BetterDisplayManager {
    var isBDInstalled: Bool = false
    var isBDRunning: Bool = false
    
    private var bdBundle = "pro.betterdisplay.BetterDisplay"
    
    init() {
        isBDInstalled = checkIfInstalled()
        if isBDInstalled {
            isBDRunning = checkIfRunning()
            if isBDRunning {
                requestBDSettings()
            }
            setupObservers()
        }
    }
    
    deinit {
        removeObservers()
    }
    
    private func checkIfInstalled() -> Bool {
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: bdBundle) != nil
    }
    
    private func checkIfRunning() -> Bool {
        return NSRunningApplication.runningApplications(withBundleIdentifier: bdBundle).isEmpty == false
    }
    
    private func setupObservers() {
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(betterDisplayNotificaiton),
            name: .init("com.betterdisplay.BetterDisplay.osd"),
            object: nil
        )
        
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               app.bundleIdentifier == self?.bdBundle {
                self?.isBDRunning = true
            }
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               app.bundleIdentifier == self?.bdBundle {
                self?.isBDRunning = false
            }
        }
    }
    
    private func removeObservers() {
        DistributedNotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    @objc private func betterDisplayNotificaiton(notification: NSNotification) {
        guard let notificationString = notification.object as? String else {
            return
        }
        do {
            let notification = try JSONDecoder().decode(BetterDisplayNotification.self, from: Data(notificationString.utf8))
            if let type = notification.controlTarget, type.contains("Brightness") {
                BrightnessManager.shared.brightness = (notification.value ?? 0) / (notification.maxValue ?? 0)
                Task { @MainActor in
                    NotchManager.shared.showExtensionNotch(type: .brightness, duration: Defaults[.displayDuration])
                }
            } else if let type = notification.controlTarget, type.contains("volume") {
                VolumeManager.shared.volume = (notification.value ?? 0) / (notification.maxValue ?? 0)
                Task { @MainActor in
                    NotchManager.shared.showExtensionNotch(type: .volume, duration: Defaults[.displayDuration])
                }
            }
        } catch {}
    }
    
    private func requestBDSettings() {
        guard isBDRunning else { return }
        
        let bdRequest = IntegrationNotificationRequestData(
            uuid: UUID().uuidString,
            commands: ["set"],
            parameters: ["osdShowBasic": "off", "osdIntegrationNotification": "on"]
        )
        
        do {
            let encoded = try JSONEncoder().encode(bdRequest)
            if let string = String(data: encoded, encoding: .utf8) {
                DistributedNotificationCenter.default().postNotificationName(
                    NSNotification.Name("com.betterdisplay.BetterDisplay.request"),
                    object: string,
                    userInfo: nil,
                    deliverImmediately: true
                )
            }
        } catch {
            print("Error decoding request: \(error)")
        }
        
    }
}

struct BetterDisplayNotification: Codable {
  var displayID: Int? = nil // Which display should show the OSD
  var systemIconID: Int? = nil // 1 - brightness, 3 - volume, 4 - mute, 0 - no icon
  var customSymbol: String? = nil // SF Symbol name if a custom icon is used
  var text: String? = nil // Text if additional text is displayed in the OSD HUD by the app
  var lock: Bool? = nil // Shows lock icon as well
  var controlTarget: String? = nil // Further description of the type of control the OSD is displayed for
  var value: Double? = nil // OSD value (scale: 0-max value)
  var maxValue: Double? = nil // max value
  var symbolFadeAfter: Int? = nil // If the symbol is a secondary symbol, it should be faded after this time elapsed - in milliseconds
  var symbolSizeMultiplier: Double? = nil // Symbol size adjustment (compared to normal size)
  var textFadeAfter: Int? = nil // Text should be faded after this time elapsed - in milliseconds
}

struct IntegrationNotificationRequestData: Codable {
  var uuid: String?
  var commands: [String] = []
  var parameters: [String: String?] = [:]
}
