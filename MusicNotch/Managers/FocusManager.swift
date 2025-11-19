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
    var color: String?
}

class FocusManager: ObservableObject {
    static let shared = FocusManager()
    
    @Published var focus = FocusMode(name: "Unknown", icon: nil, color: nil)
    
    init() {
        setupObservers()
        print("setup observers")
    }
    
    deinit {
        DistributedNotificationCenter.default.removeObserver(self)
    }
    
    private func setupObservers() {
        DistributedNotificationCenter.default.addObserver(
            forName: NSNotification.Name("_NSDoNotDisturbEnabledNotification"),
            object: nil, queue: nil
        ) { _ in
            self.readFocusMode()
        }
        
        DistributedNotificationCenter.default.addObserver(
            forName: NSNotification.Name("_NSDoNotDisturbDisabledNotification"),
            object: nil, queue: nil
        ) { _ in
            self.readFocusMode()
        }
    }
    
    private func readFocusMode() {
        print("focus notification")
 //       focus = getCurrentFocus()
//        print(focus.name)
//        print(focus.icon)
//        print(focus.color)
        
        do {
            focus = try currentFocusMode()
            print(focus.name)
            print(focus.icon)
        } catch {
            print("Failed to read Focus mode:", error)
        }
    }
    
    private func getCurrentFocus() -> FocusMode {
        
        return FocusMode(name: "No focus", icon: "", color:"")
    }
    
    
}



func currentFocusMode() throws -> FocusMode {
    func loadJSON<T: Decodable>(at path: String, as type: T.Type) throws -> T {
        let expandedPath = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    struct AssertionsRoot: Decodable { let data: [AssertionsData] }
    struct AssertionsData: Decodable {
        let storeAssertionRecords: [AssertionRecord]?
    }
    struct AssertionRecord: Decodable {
        let assertionDetails: AssertionDetails
    }
    struct AssertionDetails: Decodable {
        let assertionDetailsModeIdentifier: String
    }

    struct ModesRoot: Decodable { let data: [ModesData] }
    struct ModesData: Decodable {
        let modeConfigurations: [String: ModeConfiguration]
    }
    struct ModeConfiguration: Decodable {
        let mode: Mode
        let triggers: Triggers?
    }
    struct Mode: Decodable {
        let name: String
        let systemImageName: String?
        let tintColorName: String?

        enum CodingKeys: String, CodingKey {
            case name
            case systemImageName
            case tintColorName
            case glyphName
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            name = try c.decode(String.self, forKey: .name)
            // Prefer systemImageName, fall back to glyphName if present in some configs
            systemImageName = try c.decodeIfPresent(String.self, forKey: .systemImageName)
                ?? c.decodeIfPresent(String.self, forKey: .glyphName)
            tintColorName = try c.decodeIfPresent(String.self, forKey: .tintColorName)
        }
    }
    struct Triggers: Decodable {
        let triggers: [Trigger]?
    }
    struct Trigger: Decodable {
        let enabledSetting: Int
        let timePeriodStartTimeHour: Int?
        let timePeriodStartTimeMinute: Int?
        let timePeriodEndTimeHour: Int?
        let timePeriodEndTimeMinute: Int?
    }

    let assertions: AssertionsRoot = try loadJSON(
        at: "~/Library/DoNotDisturb/DB/Assertions.json",
        as: AssertionsRoot.self
    )
    let modes: ModesRoot = try loadJSON(
        at: "~/Library/DoNotDisturb/DB/ModeConfigurations.json",
        as: ModesRoot.self
    )

    var focus = FocusMode(name: "No focus", icon: "", color: "")

    if let manual = assertions.data.first?.storeAssertionRecords,
       let modeID = manual.first?.assertionDetails.assertionDetailsModeIdentifier,
       let config = modes.data.first?.modeConfigurations[modeID] {
        focus.name = config.mode.name
        focus.icon = config.mode.systemImageName  // fallback or nil if you prefer
        focus.color = config.mode.tintColorName
    } else if let configurations = modes.data.first?.modeConfigurations {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let now = (components.hour ?? 0) * 60 + (components.minute ?? 0)

        for (_, config) in configurations {
            guard let trigger = config.triggers?.triggers?.first,
                  trigger.enabledSetting == 2 else { continue }

            guard let startHour = trigger.timePeriodStartTimeHour,
                  let startMinute = trigger.timePeriodStartTimeMinute,
                  let endHour = trigger.timePeriodEndTimeHour,
                  let endMinute = trigger.timePeriodEndTimeMinute else {
                continue
            }

            let start = startHour * 60 + startMinute
            let end = endHour * 60 + endMinute

            if start < end {
                if now >= start && now < end {
                    focus.name = config.mode.name
                }
            } else if start > end {
                if now >= start || now < end {
                    focus.name = config.mode.name
                }
            }
        }
    }

    return focus
}

