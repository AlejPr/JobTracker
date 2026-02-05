//
//  JobListing.swift
//  JobTracker
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
    var workLocationType: WorkLocationType?
    var salaryType: SalaryType?
    var URL: URL
    var applicationStatus: JobApplicationStatus
    
    init(title: String, company: String, location: String? = nil, URL: URL, payRange: String? = nil, schedule: String? = nil, workLocationType: WorkLocationType? = nil, salaryType: SalaryType? = nil, date: Date = Date()) {
        self.title = title
        self.company = company
        self.timeStampApplied = date
        self.location = location
        self.URL = URL
        self.payRange = payRange
        self.schedule = schedule
        self.workLocationType = workLocationType
        self.salaryType = salaryType
        self.applicationStatus = .applied
    }
    
}

enum JobApplicationStatus: String, Codable {
    case applied = "Applied",
         rejected = "Rejected",
         ghosted = "Ghosted",
         interviewing = "Interviewing",
         offerPending = "Offer Pending",
         accepted = "Accepted",
         saved = "Saved"
    
    var description: String {
        self.rawValue
    }
}

enum WorkLocationType: String, Codable, CaseIterable {
    case onSite = "On-Site"
    case hybrid = "Hybrid"
    case remote = "Remote"
}

enum SalaryType: String, Codable, CaseIterable {
    case yearly = "Yearly"
    case monthly = "Monthly"
    case biWeekly = "Bi-Weekly"
    case weekly = "Weekly"
    case hourly = "Hourly"
}

let sampleData: [JobListing] = [
    JobListing(title: "Swift Software Engineer", company: "Apple", location: "Cupertino, California", URL: URL(string: "https://apple.com")!, payRange: "$150-200k", schedule: "Full-Time", date: dateFormatter.date(from: "2026-02-01")!),
    JobListing(title: "Junior Backend Developer", company: "Microsoft", location: "Redmond, Washington", URL: URL(string: "https://microsoft.com")!, payRange: "$120-180k", schedule: "Full-Time", date: dateFormatter.date(from: "2026-02-01")!),
    JobListing(title: "UX Engineer, iOS, Google Search App", company: "Google", location: "California", URL: URL(string: "https://google.com")!, payRange: "Not Provided", schedule: "Full-Time", date: dateFormatter.date(from: "2026-01-15")!),
    JobListing(title: "iOS Engineer (Audible)", company: "Amazon", location: "Austin, Texas", URL: URL(string: "https://amazon.com")!, payRange: "$140-180k", schedule: "Full-Time", date: dateFormatter.date(from: "2026-01-15")!),
    JobListing(title: "iOS Frameworks Engineer, Platform Privacy", company: "Apple", location: "Cupertino, California", URL: URL(string: "https://apple.com")!, payRange: "$120-180k", schedule: "Full-Time", date: dateFormatter.date(from: "2026-01-15")!),
    JobListing(title: "Wagie", company: "Amazon", location: "Hell", URL: URL(string: "https://amazon.com")!, payRange: "$12/hr", schedule: "Suicidal", date: dateFormatter.date(from: "2026-01-02")!)
]

fileprivate var dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    return df
}()

