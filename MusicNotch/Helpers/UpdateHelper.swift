//
//  UpdateHelper.swift
//  MusicNotch
//
//  Created by Noah Johann on 11.08.25.
//

import Sparkle

final class UpdateHelper: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

final class UpdaterWrapper {
    static let shared = UpdaterWrapper()

    let updaterController: SPUStandardUpdaterController

    private init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }
}
