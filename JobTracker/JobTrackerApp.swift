//
//  JobTrackerApp.swift
//  JobTracker
//

import SwiftUI
import SwiftData

@main
struct JobTrackerApp: App {
    
    let sharedModelContainer = SwiftDataContainer(false)

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(sharedModelContainer)
        }
        .modelContainer(sharedModelContainer.modelContainer)
        .windowResizability(.contentMinSize)
    }
}
