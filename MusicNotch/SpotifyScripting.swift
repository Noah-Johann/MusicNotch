
import Foundation

class SpotifyController {
    // Play/Pause-Funktion
    static func playpause() -> Bool {
        return executeAppleScript("""
        tell application "Spotify"
            if it is running then
                playpause
                return true
            else
                return false
            end if
        end tell
        """)?.booleanValue ?? false
    }
    
    // Prüfen, ob Spotify läuft
    static func isRunning() -> Bool {
        return executeAppleScript("""
        tell application "System Events"
            return (exists process "Spotify")
        end tell
        """)?.booleanValue ?? false
    }
    
    // Hilfsfunktion zum Ausführen von AppleScript
    private static func executeAppleScript(_ script: String) -> NSAppleEventDescriptor? {
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        let result = appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript-Fehler: \(error)")
            return nil
        }
        return result
    }
}
