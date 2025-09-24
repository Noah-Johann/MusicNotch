//
//  PermissionButton.swift
//  MusicNotch
//
//  Created by Noah Johann on 24.09.25.
//

import SwiftUI
import Luminare

@ViewBuilder
func PermissionButton(permissionName: String, granted: Bool, icon: String, action: @escaping () -> Void = {}) -> some View {
    
    Button {
        action()
    } label: {
        HStack(spacing: 12) {
            if granted == true {
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.accentColor)
            } else {
                Image(systemName: "xmark.seal.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.red.opacity(0.8))
            }


            VStack(alignment: .leading) {
                Text(permissionName)
            }

            Spacer()
        }
        .padding(8)
    }
    .buttonStyle(LuminareCosmeticButtonStyle(icon: Image(systemName: icon)))
}
//#Preview {
//    PermissionButton(permissionName: "Accesibility Permissions", granted: true)
//}
