//
//  AlbumArtView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import SwiftUI

struct AlbumArtView: View {
    @Binding var playing: Bool
    var size: Double
    var shrink: Double
    var cornerRadius: Double
    var nsImage: NSImage
    
    private var calculatedArtworkSize: CGFloat {
        if playing == true { return size } else {
            return size - shrink
        }
    }
    
    private var calculatedCornerRadius: CGFloat {
        if playing == true { return cornerRadius } else {
            let relativeRadius = cornerRadius / size
            return (size - shrink) * relativeRadius
        }
    }
    
    var body: some View {
        HStack {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .frame(width: calculatedArtworkSize,
                       height: calculatedArtworkSize)
                .cornerRadius(calculatedCornerRadius)
                .animation(.easeInOut(duration: 0.3), value: calculatedArtworkSize)
                .animation(.easeInOut(duration: 0.3), value: calculatedCornerRadius)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    AlbumArtView(playing: .constant(true), size: 80, shrink: 10, cornerRadius: 20, nsImage: NSImage(named: "no_playback")!)
        .padding(60)
}
