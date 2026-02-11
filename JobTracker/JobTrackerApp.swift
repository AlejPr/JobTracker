//
//  JobTrackerApp.swift
//  JobTracker
//

import SwiftUI
import SwiftData

@main
struct JobTrackerApp: App {
    
    let sharedModelContainer = SwiftDataContainer(true)

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(sharedModelContainer)
        }
        .modelContainer(sharedModelContainer.modelContainer)
        .windowResizability(.contentMinSize)
    }
}
