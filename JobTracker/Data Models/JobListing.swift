//
//  JobListing.swift
//  JobTracker
//


import SwiftUI
import SwiftData

@Model
final class JobListing: Identifiable, Hashable, CustomStringConvertible {
    
    var title: String
    var company: String
    var timeStampApplied: Date
    var jobURL: URL?
    var location: String?
    var payRange: String?
    var schedule: String?
    var notes: String?
    var workLocationType: WorkLocationType?
    var salaryType: SalaryType?
    var applicationStatus: ApplicationStatus
    
    init(title: String, company: String, location: String? = nil, jobURL: URL?, payRange: String? = nil, schedule: String? = nil, notes: String? = nil, workLocationType: WorkLocationType? = nil, salaryType: SalaryType? = nil, date: Date = Date(), applicationStatus: ApplicationStatus = .applied) {
        self.title = title
        self.company = company
        self.timeStampApplied = date
        self.location = location
        self.jobURL = jobURL
        self.payRange = payRange
        self.schedule = schedule
        self.workLocationType = workLocationType
        self.salaryType = salaryType
        self.applicationStatus = applicationStatus
        self.notes = notes
    }
    
    var description: String { return "Joblisting for role \(title) at \(company)."}
    
}

extension JobListing {
    
    enum ApplicationStatus: String, Codable {
        case applied = "Applied",
             rejected = "Rejected",
             ghosted = "Ghosted",
             interviewing = "Interviewing",
             offerPending = "Offer Pending",
             accepted = "Accepted",
             saved = "Saved",
             emailed = "Emailed"
        
        var description: String {
            self.rawValue
        }
        
        var color: Color {
            switch self {
            case .applied: Color.blue.opacity(0.2)
            case .rejected: Color.red.opacity(0.4)
            case .ghosted: Color.gray.opacity(0.15)
            case .interviewing: Color.purple.opacity(0.15)
            case .offerPending: Color.yellow.opacity(0.15)
            case .accepted: Color.green.opacity(0.15)
            case .saved: Color.blue.opacity(0.2)
            case .emailed: Color.blue.opacity(0.2)
            }
            
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
    
}


//MARK: - Sample Data
extension JobListing {
    
    // Helper function to create dates safely
    private static func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static var sampleData: [JobListing] {[
        JobListing(
            title: "Unemployment assistance",
            company: "Government",
            location: "Florida",
            jobURL: URL(string: "https://apple.com")!,
            payRange: "$1k",
            salaryType: .monthly,
            applicationStatus: .accepted
        ),
        JobListing(
            title: "Swift Software Engineer",
            company: "Apple",
            location: "Cupertino, California",
            jobURL: URL(string: "https://apple.com")!,
            payRange: "$150-200k",
            schedule: "Full-Time",
            notes: "REALLY want this job!!!!! Apple Campus is very beautiful.\nAlso 996 work schedule",
            date: makeDate(year: 2026, month: 2, day: 1, hour: 11),
            applicationStatus: .rejected
        ),
        JobListing(
            title: "Junior Backend Developer",
            company: "Microsoft",
            location: "Redmond, Washington",
            jobURL: URL(string: "https://microsoft.com")!,
            payRange: "$120-180k",
            schedule: "Full-Time",
            date: makeDate(year: 2026, month: 2, day: 1, hour: 12),
            applicationStatus: .interviewing
        ),
        JobListing(
            title: "Weird Job",
            company: "Local Company",
            jobURL: URL(string: "https://test.com")!,
            date: makeDate(year: 2026, month: 2, day: 1, hour: 13),
            applicationStatus: .applied
        ),
        JobListing(
            title: "UX Engineer, iOS, Google Search App",
            company: "Google",
            location: "California",
            jobURL: URL(string: "https://google.com")!,
            payRange: "Not Provided",
            schedule: "Full-Time",
            date: makeDate(year: 2026, month: 1, day: 15, hour: 11),
            applicationStatus: .rejected
        ),
        JobListing(
            title: "iOS Engineer (Audible)",
            company: "Amazon",
            location: "Austin, Texas",
            jobURL: URL(string: "https://amazon.com")!,
            payRange: "$140-180k",
            schedule: "Full-Time",
            date: makeDate(year: 2026, month: 1, day: 15, hour: 12),
            applicationStatus: .ghosted
        ),
        JobListing(
            title: "iOS Frameworks Engineer, Platform Privacy",
            company: "Apple",
            location: "Cupertino, California",
            jobURL: URL(string: "https://apple.com")!,
            payRange: "$120-180k",
            schedule: "Full-Time",
            date: makeDate(year: 2026, month: 1, day: 15, hour: 13),
            applicationStatus: .ghosted
        ),
        JobListing(
            title: "Wagie",
            company: "Amazon",
            location: "Hell",
            jobURL: URL(string: "https://amazon.com")!,
            payRange: "$12/hr",
            schedule: "Suicidal",
            date: makeDate(year: 2026, month: 1, day: 2, hour: 12),
            applicationStatus: .offerPending
        )
    ]}
    
}

typealias WorkLocationType = JobListing.WorkLocationType
typealias SalaryType = JobListing.SalaryType
typealias ApplicationStatus = JobListing.ApplicationStatus
