//
//  SettingsPermissionView.swift
//  MusicNotch
//
//  Created by Noah Johann on 24.09.25.
//

import Foundation
import SwiftUI
import Luminare

struct SettingsPermissionView: View {
    @State private var isAccessibilityGranted: Bool = false
    
    var body: some View {
        LuminareSection {
            PermissionButton(permissionName: "Accessibility Permission",
                             granted: isAccessibilityGranted,
                             icon: "arrow.counterclockwise",
            ) {
                isAccessibilityGranted = AccessibilityHelper.isAuthorized(prompt: true)
            }
            
        } header: {
            Text("Permissions")
        }
        .padding(.bottom, 14)
        .onAppear{
            isAccessibilityGranted = AccessibilityHelper.isAuthorized(prompt: false)
        }
    }
}
