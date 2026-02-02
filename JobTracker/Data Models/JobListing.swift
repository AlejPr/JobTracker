//
//  JobListing.swift
//  JobTracker
//
//  Created by Alejandro on 1/31/26.
//

import Foundation
import SwiftData

@Model
final class JobListing: Identifiable, Hashable {
    var title: String
    var company: String
    var timeStampApplied: Date
    var location: String?
    var payRange: String?
    var schedule: String?
    var URL: URL
    
    init(title: String, company: String, location: String? = nil, URL: URL, payRange: String? = nil, schedule: String? = nil) {
        self.title = title
        self.company = company
        self.timeStampApplied = Date()
        self.location = location
        self.URL = URL
        self.payRange = payRange
        self.schedule = schedule
    }
    
}

let sampleData: [JobListing] = [
    JobListing(title: "Swift Software Engineer", company: "Apple", location: "Cupertino, California", URL: URL(string: "https://apple.com")!, payRange: "$150-200k", schedule: "Full-Time"),
    JobListing(title: "Junior Backend Developer", company: "Microsoft", location: "Redmond, Washington", URL: URL(string: "https://microsoft.com")!, payRange: "$120-180k", schedule: "Full-Time"),
    JobListing(title: "Wagie", company: "Amazon", location: "Hell", URL: URL(string: "https://amazon.com")!, payRange: "$12/hr", schedule: "Suicidal")
]
