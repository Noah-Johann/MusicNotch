//
//  GadgetsPickerView.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.10.25.
//

import Defaults
import SwiftUI
import Luminare

@MainActor
class GadgetsConfigurationModel: ObservableObject {
    // MARK: Defaults
    
    @Published var topGadgets = Defaults[.topGadgets] {
        didSet { Defaults[.topGadgets] = topGadgets }
    }
    
    @Published var bottomGadgets = Defaults[.bottomGadgets] {
        didSet { Defaults[.bottomGadgets] = bottomGadgets }
    }
    
    var gadgetsOption: GadgetsPosition {
        get {
            topGadgets ? .topGadgets : .bottomGadgets
        }
        set {
            topGadgets = newValue == .topGadgets
            bottomGadgets = newValue == .bottomGadgets
          //  selectionChanged(to: newValue)
        }
    }

//    /// Called whenever the user changes the display selection.
//    func selectionChanged(to newValue: GadgetsPosition) {
//        Task {
//            await NotchManager.shared.setNotchContent(.closed, true)
//        }
//    }
}

enum GadgetsPosition: CaseIterable {
    case topGadgets
    case bottomGadgets
    
//    var image: Image {
//        switch self {
//        case .top: Image(systemName: "macbook")
//                .resizable()
//        case .mainDisplay: Image(systemName: "display.2")
//                .resizable()
//        }
//    }
    
    var text: LocalizedStringKey {
        switch self {
        case .topGadgets: "Top"
        case .bottomGadgets: "Bottom"
        }
    }
}

struct GadgetsPickerView: View {
    @StateObject private var model = GadgetsConfigurationModel()
    
    var body: some View {
        LuminarePicker(
            elements: GadgetsPosition.allCases,
            selection: Binding(
                get: { model.gadgetsOption},
                set: { model.gadgetsOption = $0 }
            ),
           // .animation(LuminareConstants.animation),
            columns: 2
        ) { option in
            VStack(spacing: 6) {
//                option.image
//                    .scaledToFit()
//                    .frame(width: 30, height: 40)
                Text(option.text)
                    .font(.title3)
            }
        }
    }
}

#Preview {
    DisplayPickerView()
}

