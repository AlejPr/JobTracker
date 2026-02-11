//
//  SwiftDataContainer.swift
//  JobTracker
//

import SwiftData
import SwiftUI


@Observable
@MainActor
class SwiftDataContainer {
    let modelContainer: ModelContainer
    var context: ModelContext { modelContainer.mainContext }
    
    init(_ memoryOnly: Bool = false) {
        let schema = Schema([
            JobListing.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: memoryOnly)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            if memoryOnly { loadSampleData() }
            
        } catch {
            //TODO: - implement a pop up or something
            fatalError("Could not initialize SwiftData container with error: \(error)")
        }
    }
    
    private func loadSampleData() {
        for listing in JobListing.sampleData {
            context.insert(listing)
        }
    }
    
}


let sampleDataContainer = SwiftDataContainer(true)

extension View {
    func sampleContainer() -> some View {
        self
            .environment(sampleDataContainer)
            .modelContainer(sampleDataContainer.modelContainer)
    }
}
