//
//  Music_AppApp.swift
//  Music App
//
//  Created by Nathan Davis on 10/31/23.
//

import SwiftUI
import SwiftData

@main
struct Music_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PianoPiece.self,
            TallyMethodEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schema changed during development — wipe the old store and start fresh
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let storeURL = appSupport.appendingPathComponent("default.store")
            for ext in ["", "-shm", "-wal"] {
                let url = URL(fileURLWithPath: storeURL.path + ext)
                try? FileManager.default.removeItem(at: url)
            }
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

