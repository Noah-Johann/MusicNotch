import Foundation
import AppKit
import DynamicNotchKit
import SkyLightWindow

public extension DynamicNotch {
    @discardableResult
    func moveToSky() -> Self {
        Task { @MainActor in
            // If the window already exists, delegate it immediately
            if let window = self.windowController?.window {
                SkyLightOperator.shared.delegateWindow(window)
                return
            }
            // Otherwise, wait briefly for the window to be created (e.g., after expand/compact)
            for _ in 0..<20 { // up to ~1s total
                try? await Task.sleep(nanoseconds: 50_000_000)
                if let window = self.windowController?.window {
                    SkyLightOperator.shared.delegateWindow(window)
                    break
                }
            }
        }
        return self
    }
}
