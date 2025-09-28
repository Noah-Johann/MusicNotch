//
//  ExtensionLockView.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.09.25.
//

import Foundation
import SwiftUI

enum LockType {
    case locked
    case unlocked
}

struct ExtensionLockViewLeading: View {
    let lockType: LockType
    
    var body: some View {
        switch lockType {
        case .locked:
            Image(systemName: "lock.fill")
                .imageScale(.large)
                .frame(width: 20, height: 20)
        case .unlocked:
            Image(systemName: "lock.open.fill")
                .imageScale(.large)
                .frame(width: 20, height: 20)
        }
        
    }
}

struct ExtensionLockViewTrailing: View {
    var body: some View {
        VStack {}
            .frame(width: 20, height: 20)
    }
}
