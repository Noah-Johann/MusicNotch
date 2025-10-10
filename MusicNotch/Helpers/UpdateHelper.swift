//
//  UpdateHelper.swift
//  MusicNotch
//
//  Created by Noah Johann on 11.08.25.
//


import Foundation
import Sparkle
import AppKit
import Defaults

enum UpdateState: Equatable {
    case idle
    case checking
    case noUpdates
    case updateAvailable
    case downloading
    case extracting
    case readyToInstall
    case installing
    case installed
    case error
}


// MARK: - UpdateManager Singleton integrating Sparkle with CustomUserDriver

@MainActor
final class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    private var updater: SPUUpdater!
    
    @Published var updateState: UpdateState = .idle
    @Published var updateSize: Double = 1.0
    @Published var downloadedSize: Double = 0
    @Published var newVersionNumber: String = "0.0.0"
    @Published var updateProgress: CGFloat = 0
    
    
    
    private init() {
        let userDriver = CustomUserDriver(updater: nil)
        updater = SPUUpdater(
            hostBundle: Bundle.main,
            applicationBundle: Bundle.main,
            userDriver: userDriver,
            delegate: nil
        )
        userDriver.updater = updater
        userDriver.manager = self
        
        updater.automaticallyChecksForUpdates = Defaults[.autoUpdates]
        updater.automaticallyDownloadsUpdates = Defaults[.autoUpdates]
        
        do {
            try updater.start()
        } catch {
            print("Failed to start Sparkle updater: \(error)")
        }
    }
    
    func checkForUpdates(fromMenuBar: Bool = false) {
        updater.checkForUpdates()
        if fromMenuBar {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.downloadUpdate()
            }
        }
    }
    
    func updateAutoSettings() {
        updater.automaticallyChecksForUpdates = Defaults[.autoUpdates]
        updater.automaticallyDownloadsUpdates = Defaults[.autoUpdates]
    }

    func downloadUpdate() {
        if let userDriver = updater.value(forKey: "userDriver") as? CustomUserDriver {
            userDriver.proceedWithDownload()
        }
    }
    
    func installUpdate() {
        if let userDriver = updater.value(forKey: "userDriver") as? CustomUserDriver {
            userDriver.proceedWithInstall()
        }
    }
}

@MainActor
final class CustomUserDriver: NSObject, @MainActor SPUUserDriver {
    
    var updater: SPUUpdater?
    weak var manager: UpdateManager?
    private var progressWindow: NSWindow?
    
    // Store the reply callbacks to call them later when user presses button
    private var downloadReply: ((SPUUserUpdateChoice) -> Void)?
    private var installReply: ((SPUUserUpdateChoice) -> Void)?
    
    init(updater: SPUUpdater?) {
        self.updater = updater
        super.init()
    }

    // MARK: - Manual Control Methods
    
    func proceedWithDownload() {
        if let reply = downloadReply {
            downloadReply = nil
            reply(.install)
        }
    }
    
    func proceedWithInstall() {
        if let reply = installReply {
            installReply = nil
            reply(.install)
        }
    }


    // MARK: - Required Methods

    func show(_ request: SPUUpdatePermissionRequest, reply: @escaping (SUUpdatePermissionResponse) -> Void) {
        // Called the first time Sparkle runs
        let response = SUUpdatePermissionResponse(automaticUpdateChecks: true, sendSystemProfile: false)
        reply(response)
    }

    func showUserInitiatedUpdateCheck(cancellation: @escaping () -> Void) {
        // Example: show a custom loading window
        print("User initiated update check…")
        manager?.updateState = .checking
    }

    func showUpdateFound(with appcastItem: SUAppcastItem, state: SPUUserUpdateState, reply: @escaping (SPUUserUpdateChoice) -> Void) {
        print("Update found: \(appcastItem.displayVersionString)")
        manager?.updateState = .updateAvailable
        manager?.newVersionNumber = appcastItem.displayVersionString
        
        // Store the reply callback instead of calling it immediately
        downloadReply = reply
        // Don't call reply here - wait for user to press download button
    }

    func showUpdateReleaseNotes(with downloadData: SPUDownloadData) {
        // Optional: display release notes in your own UI
        print("Release notes available")
    }

    func showUpdateReleaseNotesFailedToDownload(with error: Error) {
        print("Failed to download release notes: \(error)")
    }

    func showUpdateNotFound(with error: Error, acknowledgement: @escaping () -> Void) {
        print("No updates found: \(error.localizedDescription)")
        manager?.updateState = .noUpdates
        acknowledgement()
    }

    func showUpdaterError(_ error: Error, acknowledgement: @escaping () -> Void) {
        print("Updater error: \(error.localizedDescription)")
        manager?.updateState = .error
        acknowledgement()
    }

    func showDownloadInitiated(cancellation: @escaping () -> Void) {
        print("Download started…")
        manager?.downloadedSize = 0
        manager?.updateState = .downloading
    }

    func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
        print("Expected content length: \(expectedContentLength) bytes")
        manager?.updateSize = Double(expectedContentLength)
    }

    func showDownloadDidReceiveData(ofLength length: UInt64) {
        manager?.downloadedSize += Double(length)
        manager?.updateProgress = (manager?.downloadedSize ?? 0) / (manager?.updateSize ?? 1000000)
//        print("Downloaded \(manager!.downloadedSize) bytes")
//        print("Progress \(manager!.updateProgress)")

    }

    func showDownloadDidStartExtractingUpdate() {
        print("Extracting update…")
        manager?.updateState = .extracting
    }

    func showExtractionReceivedProgress(_ progress: Double) {
        print("Extraction progress: \(progress * 100)%")
    }

    func showReady(toInstallAndRelaunch reply: @escaping (SPUUserUpdateChoice) -> Void) {
        print("Ready to install and relaunch")
        manager?.updateState = .readyToInstall
        
        // Store the reply callback instead of calling it immediately
        installReply = reply
        // Don't call reply here - wait for user to press install button
    }

    func showInstallingUpdate(withApplicationTerminated applicationTerminated: Bool, retryTerminatingApplication: @escaping () -> Void) {
        print("Installing update (terminated: \(applicationTerminated))")
        manager?.updateState = .installing
    }

    func showUpdateInstalledAndRelaunched(_ relaunched: Bool, acknowledgement: @escaping () -> Void) {
        manager?.updateState = .installed
        acknowledgement()
    }

    func showUpdateInFocus() {
        print("Bring update window to focus")
    }

    func dismissUpdateInstallation() {
        print("Dismiss update UI")
        // Clear any pending replies
        downloadReply = nil
        installReply = nil
        
    }
    
    func showUpdateReleaseNotesFailedToDownloadWithError(_ error: any Error) {
        print("Failed to download release notes: \(error.localizedDescription)")
    }
    
    func showUpdateNotFoundWithError(_ error: any Error, acknowledgement: @escaping () -> Void) {
        print("No updates found: \(error.localizedDescription)")
        manager?.updateState = .noUpdates
        acknowledgement()
    }
}

