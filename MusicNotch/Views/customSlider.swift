//
//  customSlider.swift
//  MusicNotch
//
//  Created by Noah Johann on 19.03.25.
//

import SwiftUI

struct customSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var onEditingChanged: (Bool) -> Void
    var onProgressUpdate: (Int) -> Void  
    
    // Slider configuration
    var standardHeight: CGFloat = 4
    var expandedHeight: CGFloat = 8
    var trackColor: Color = Color.white.opacity(0.3)
    var fillColor: Color = .white
    
    // Gesture state
    @State public var isDragging = false
    
    private var minimumValue: Double { range.lowerBound }
    private var maximumValue: Double { range.upperBound }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(trackColor)
                    .frame(height: isDragging ? expandedHeight : standardHeight)
                    .animation(.easeOut(duration: 0.2), value: isDragging)
                
                // Filled track
                Capsule()
                    .fill(fillColor)
                    .frame(width: filledWidth(totalWidth: geometry.size.width),
                           height: isDragging ? expandedHeight : standardHeight)
                    .animation(.easeOut(duration: 0.2), value: isDragging)
            }
            .contentShape(Rectangle()) // Make the whole area tappable
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged(true)
                        }
                        
                        let width = geometry.size.width
                        let dragPosition = gesture.location.x
                        let clampedPosition = min(max(0, dragPosition), width)
                        
                        // Update value based on drag position
                        let percentage = clampedPosition / width
                        let newValue = minimumValue + (maximumValue - minimumValue) * Double(percentage)
                        value = newValue
                        
                        // Update progress as Int
                        updateProgress()
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged(false)
                        // Final update on end of drag
                        updateProgress()
                    }
            )
            .onChange(of: value) { _, _ in
                if !isDragging {
                    // Update progress when value changes externally
                    updateProgress()
                }
            }
        }
        .frame(height: isDragging ? expandedHeight : standardHeight)
        .animation(.easeOut(duration: 0.2), value: isDragging)
    }
    
    private func filledWidth(totalWidth: CGFloat) -> CGFloat {
        let percentage = (value - minimumValue) / (maximumValue - minimumValue)
        return max(0, min(CGFloat(percentage) * totalWidth, totalWidth))
    }
    
    private func updateProgress() {
        if !isDragging {
            // Update the slider value from the SpotifyManager
            value = Double(SpotifyManager.shared.trackPosition)
            
            // Call the onProgressUpdate closure to update the progress
            let progress = Int(value)  // Convert the slider value to an integer
            onProgressUpdate(progress) // Pass the progress to the closure
        }
    }
}


//Preview
struct ControlCenterSlider_Previews: PreviewProvider {
    @State static var previewValue: Double = 30
    @State static var progressValue: Int = 30
    
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Progress: \(progressValue)")
                    .foregroundColor(.white)
                customSlider(
                    value: $previewValue,
                    range: 0...100,
                    onEditingChanged: { _ in },
                    onProgressUpdate: { progress in
                        progressValue = progress
                    }
                )
            }
            .padding(.horizontal, 24)
        }
        .previewLayout(.sizeThatFits)
        .frame(height: 100)
    }
}


