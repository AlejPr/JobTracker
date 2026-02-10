//
//  SwiftDataContainer.swift
//  JobTracker
//

import SwiftData
import SwiftUI


@Observable
@MainActor
class SwiftDataContainer {
    var modelContainer: ModelContainer
    var context: ModelContext { return modelContainer.mainContext }
    
    init(memoryOnly: Bool = false) {
        let schema = Schema([
            JobListing.self
        ])
        
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: memoryOnly)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
            
            if memoryOnly { loadSampleData() }
            
            //try context.save()
        } catch {
            //TODO: - implement a pop up or something
            fatalError("Could not initialize Swiftdata model, \(error)")
        }
    }
    
    private func loadSampleData() {
        for listing in JobListing.sampleData {
            context.insert(listing)
        }
    }
    
}


let sampleDataContainer = SwiftDataContainer(memoryOnly: true)
