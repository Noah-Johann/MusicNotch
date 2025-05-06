//
//  DisplayPickerView.swift
//  MusicNotch
//
//  Created by Noah Johann on 22.04.25.
//

import Defaults
import SwiftUI
import Luminare

@MainActor
class DisplayConfigurationModel: ObservableObject {
    // MARK: Defaults
    
    @Published var notchDisplay = Defaults[.notchDisplay] {
        didSet { Defaults[.notchDisplay] = notchDisplay }
    }
    
    @Published var mainDisplay = Defaults[.mainDisplay] {
        didSet { Defaults[.mainDisplay] = mainDisplay }
    }
    
    var displayOption: NotchDisplay {
        get {
            notchDisplay ? .notchDisplay : .mainDisplay
        }
        set {
            notchDisplay = newValue == .notchDisplay
            mainDisplay = newValue == .mainDisplay
            selectionChanged(to: newValue)
        }
    }

    /// Called whenever the user changes the display selection.
    func selectionChanged(to newValue: NotchDisplay) {
        NotchManager.shared.setNotchContent("closed", true)
    }
}

enum NotchDisplay: CaseIterable {
    case notchDisplay
    case mainDisplay
    
    var image: Image {
        switch self {
        case .notchDisplay: Image(systemName: "macbook")
                .resizable()
        case .mainDisplay: Image(systemName: "display.2")
                .resizable()
        }
    }
    
    var text: String {
        switch self {
        case .notchDisplay: "MacBook display"
        case .mainDisplay: "Main display"
        }
    }
}

struct DisplayPickerView: View {
    @StateObject private var model = DisplayConfigurationModel()
    
    var body: some View {
        LuminarePicker(
            elements: NotchDisplay.allCases,
            selection: Binding(
                get: { model.displayOption },
                set: { model.displayOption = $0 }
            )
            .animation(LuminareConstants.animation),
            columns: 2
        ) { option in
            VStack(spacing: 6) {
                option.image
                    .scaledToFit()
                    .frame(width: 30, height: 40)
                Text(option.text)
                    .font(.title3)
            }
        }
    }
}

#Preview {
    DisplayPickerView()
}
