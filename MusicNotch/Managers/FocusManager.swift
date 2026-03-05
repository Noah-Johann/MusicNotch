//
//  FocusManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 17.11.25.
//

import SwiftUI
import Foundation

struct FocusMode {
    var name: String
    var icon: String?
    var color: NSColor?
}

class FocusManager: ObservableObject {
    static let shared = FocusManager()
    
    @Published var focus = FocusMode(name: "Unknown", icon: nil, color: nil)
    
    let watcher = FocusWatcher()
    
    init() {
        watcher.start()
    }
    
    deinit {
        DistributedNotificationCenter.default.removeObserver(self)
    }
    
    private func setupObservers() {
        DistributedNotificationCenter.default.addObserver(
            forName: NSNotification.Name("_NSDoNotDisturbEnabledNotification"),
            object: nil, queue: nil
        ) { _ in
         //   self.readFocusMode()
            
        }
        
        DistributedNotificationCenter.default.addObserver(
            forName: NSNotification.Name("_NSDoNotDisturbDisabledNotification"),
            object: nil, queue: nil
        ) { _ in
         //   self.readFocusMode()
        }
    }
    
    private func updateFocus() {
        if let focus = getActiveFocusMode() {
            print("Name:   \(focus.name)")
            print("Symbol: \(focus.icon)")       // e.g. "moon.fill", "briefcase.fill"
            print("Color:  \(String(describing: focus.color))")
            self.focus = focus
        }
    }
    
    private func getActiveFocusMode() -> FocusMode? {
        // Load frameworks
        guard
            Bundle(path: "/System/Library/PrivateFrameworks/Focus.framework")?.load() != nil,
            Bundle(path: "/System/Library/PrivateFrameworks/DoNotDisturb.framework")?.load() != nil
        else { return nil }

        // Get FCActivityManager.sharedActivityManager
        guard
            let cls = NSClassFromString("FCActivityManager"),
            let manager = (cls as AnyObject)
                .perform(Selector(("sharedActivityManager")))?
                .takeUnretainedValue() as? NSObject
        else { return nil }

        // Get active activity
        guard
            let activity = manager
                .perform(Selector(("defaultActivity")))?
                .takeUnretainedValue() as? NSObject
        else {
            print("No active focus mode")
            return nil
        }

        // Extract the three properties we want
        let name   = activity.value(forKey: "activityDisplayName") as? String ?? "Unknown"
        let symbol = activity.value(forKey: "activitySymbolImageName") as? String ?? ""

        // activityColorName returns a system color name string e.g. "systemBlue"
        var color: NSColor? = nil
        if let colorName = activity.value(forKey: "activityColorName") as? String {
            color = NSColor(named: colorName)
            if color == nil {
                color = systemColorFromName(colorName)
            }
        }

        return FocusMode(name: name, icon: symbol, color: color)
    }

    func systemColorFromName(_ name: String) -> NSColor? {
        switch name {
        case "systemBlue":   return .systemBlue
        case "systemPurple": return .systemPurple
        case "systemOrange": return .systemOrange
        case "systemGreen":  return .systemGreen
        case "systemRed":    return .systemRed
        case "systemPink":   return .systemPink
        case "systemYellow": return .systemYellow
        case "systemTeal":   return .systemTeal
        case "systemIndigo": return .systemIndigo
        case "systemMint":   return .systemMint
        case "systemCyan":   return .systemCyan
        default:             return nil
        }
    }

    // Usage

    
    
}



class FocusWatcher: NSObject {
    
    private var manager: NSObject?
    
    func start() {
        guard
            Bundle(path: "/System/Library/PrivateFrameworks/Focus.framework")?.load() != nil,
            Bundle(path: "/System/Library/PrivateFrameworks/DoNotDisturb.framework")?.load() != nil
        else {
            print("error loading framework")
            return
        }
        
        guard let cls = NSClassFromString("FCActivityManager"),
              let mgr = (cls as AnyObject)
            .perform(Selector(("newActivityManagerWithIdentifier:")), with: "com.apple.controlcenter")?
            .takeUnretainedValue() as? NSObject
        else {
            print("❌ couldn't get FCActivityManager")
            return
        }
        self.manager = mgr
        mgr.perform(Selector(("addObserver:")), with: self)
        print("✅ registered as observer")
        print("manager: \(mgr)")
        
        let active = mgr.value(forKey: "activeActivity")
        let available = mgr.value(forKey: "availableActivities")
        let isDefault = mgr.value(forKey: "isDefaultConfiguration")
        print("activeActivity: \(String(describing: active))")
        print("availableActivities: \(String(describing: available))")
        print("isDefaultConfiguration: \(String(describing: isDefault))")
        
    }
    
    func printCurrentFocus() {
        guard let mgr = manager,
              let activity = mgr.value(forKey: "activeActivity") as? NSObject
        else {
            print("No active focus mode")
            return
        }
        
        let name   = activity.value(forKey: "activityDisplayName") as? String ?? "Unknown"
        let symbol = activity.value(forKey: "activitySymbolImageName") as? String ?? ""
        let color  = activity.value(forKey: "activityColorName") as? String ?? ""
        print("name:   \(name)")
        print("symbol: \(symbol)")
        print("color:  \(color)")
    }
    
    // Called when active focus mode changes
    @objc func activeActivityDidChangeForManager(_ manager: AnyObject) {
        print("🔔 focus changed!")
        printCurrentFocus()
    }
    
    // Called when available modes list changes
    @objc func availableActivitiesDidChangeForManager(_ manager: AnyObject) {
        print("🔔 available activities changed")
    }
    
    // Called when lifetime descriptions change
    @objc func activityManager(_ manager: AnyObject,
                               lifetimeDescriptionsDidChangeForActivity activity: AnyObject) {
        print("🔔 lifetime changed for: \(activity)")
    }
}



//func currentFocusMode() throws -> FocusMode {
//    func loadJSON<T: Decodable>(at path: String, as type: T.Type) throws -> T {
//        let expandedPath = (path as NSString).expandingTildeInPath
//        let url = URL(fileURLWithPath: expandedPath)
//        let data = try Data(contentsOf: url)
//        return try JSONDecoder().decode(T.self, from: data)
//    }
//
//    struct AssertionsRoot: Decodable { let data: [AssertionsData] }
//    struct AssertionsData: Decodable {
//        let storeAssertionRecords: [AssertionRecord]?
//    }
//    struct AssertionRecord: Decodable {
//        let assertionDetails: AssertionDetails
//    }
//    struct AssertionDetails: Decodable {
//        let assertionDetailsModeIdentifier: String
//    }
//
//    struct ModesRoot: Decodable { let data: [ModesData] }
//    struct ModesData: Decodable {
//        let modeConfigurations: [String: ModeConfiguration]
//    }
//    struct ModeConfiguration: Decodable {
//        let mode: Mode
//        let triggers: Triggers?
//    }
//    struct Mode: Decodable {
//        let name: String
//        let systemImageName: String?
//        let tintColorName: String?
//
//        enum CodingKeys: String, CodingKey {
//            case name
//            case systemImageName
//            case tintColorName
//            case glyphName
//        }
//
//        init(from decoder: Decoder) throws {
//            let c = try decoder.container(keyedBy: CodingKeys.self)
//            name = try c.decode(String.self, forKey: .name)
//            // Prefer systemImageName, fall back to glyphName if present in some configs
//            systemImageName = try c.decodeIfPresent(String.self, forKey: .systemImageName)
//                ?? c.decodeIfPresent(String.self, forKey: .glyphName)
//            tintColorName = try c.decodeIfPresent(String.self, forKey: .tintColorName)
//        }
//    }
//    struct Triggers: Decodable {
//        let triggers: [Trigger]?
//    }
//    struct Trigger: Decodable {
//        let enabledSetting: Int
//        let timePeriodStartTimeHour: Int?
//        let timePeriodStartTimeMinute: Int?
//        let timePeriodEndTimeHour: Int?
//        let timePeriodEndTimeMinute: Int?
//    }
//
//    let assertions: AssertionsRoot = try loadJSON(
//        at: "~/Library/DoNotDisturb/DB/Assertions.json",
//        as: AssertionsRoot.self
//    )
//    let modes: ModesRoot = try loadJSON(
//        at: "~/Library/DoNotDisturb/DB/ModeConfigurations.json",
//        as: ModesRoot.self
//    )
//
//    var focus = FocusMode(name: "No focus", icon: "", color: "")
//
//    if let manual = assertions.data.first?.storeAssertionRecords,
//       let modeID = manual.first?.assertionDetails.assertionDetailsModeIdentifier,
//       let config = modes.data.first?.modeConfigurations[modeID] {
//        focus.name = config.mode.name
//        focus.icon = config.mode.systemImageName  // fallback or nil if you prefer
//        focus.color = config.mode.tintColorName
//    } else if let configurations = modes.data.first?.modeConfigurations {
//        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
//        let now = (components.hour ?? 0) * 60 + (components.minute ?? 0)
//
//        for (_, config) in configurations {
//            guard let trigger = config.triggers?.triggers?.first,
//                  trigger.enabledSetting == 2 else { continue }
//
//            guard let startHour = trigger.timePeriodStartTimeHour,
//                  let startMinute = trigger.timePeriodStartTimeMinute,
//                  let endHour = trigger.timePeriodEndTimeHour,
//                  let endMinute = trigger.timePeriodEndTimeMinute else {
//                continue
//            }
//
//            let start = startHour * 60 + startMinute
//            let end = endHour * 60 + endMinute
//
//            if start < end {
//                if now >= start && now < end {
//                    focus.name = config.mode.name
//                }
//            } else if start > end {
//                if now >= start || now < end {
//                    focus.name = config.mode.name
//                }
//            }
//        }
//    }
//
//    return focus
//}
//
