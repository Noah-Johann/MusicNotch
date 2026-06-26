//
//  SettingsInfoItemView.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.06.26.
//

import SwiftUI

struct SettingsInfoItemView<Content>: View where Content: View {
    var arrowEdge: Edge = .top
    @ViewBuilder public var content: () -> Content
    
    @State private var showPopover: Bool = false
    
    var body: some View {
        Image(systemName: showPopover == true ? "info.circle.fill" : "info.circle")
            .foregroundStyle(.secondary)
            .imageScale(.large)
            .onTapGesture { showPopover.toggle() }
            .popover(isPresented: $showPopover, arrowEdge: arrowEdge) {
                content()
                    .padding()
            }
    }
}

#Preview {
    SettingsInfoItemView { Text("H3") }
}
