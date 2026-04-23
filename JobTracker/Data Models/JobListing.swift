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
    var saveDataFilePath: String? = nil
    var location: String?
    var salaryRange: String?
    var schedule: String?
    var notes: String?
    var requirements: String?
    var jobDescription: String?
    var workLocationType: WorkLocationType?
    var salaryType: SalaryType?
    var applicationStatus: ApplicationStatus
    
    init(title: String, company: String, jobURL: URL?,
         location: String? = nil, salaryRange: String? = nil, schedule: String? = nil,
         notes: String? = nil, requirements: String? = nil, jobDescription: String? = nil,
         workLocationType: WorkLocationType? = nil, salaryType: SalaryType? = nil,
         date: Date = Date(), applicationStatus: ApplicationStatus = .applied) {
        self.title = title
        self.company = company
        self.timeStampApplied = date
        self.location = location
        self.jobURL = jobURL
        self.salaryRange = salaryRange
        self.schedule = schedule
        self.workLocationType = workLocationType
        self.salaryType = salaryType
        self.applicationStatus = applicationStatus
        self.notes = notes
        self.jobDescription = jobDescription
        self.requirements = requirements
    }
    
    
    init(from LLMResponse: String) {
        self.title = ""
        self.company = ""
        self.timeStampApplied = Date()
        self.applicationStatus = .applied

        guard let data = LLMResponse.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }
        
        self.title   = json["jobTitle"]    as? String ?? "Unknown Title"
        self.company = json["companyName"] as? String ?? "Unknown Company"

        self.location       = json["location"]        as? String
        self.salaryRange    = json["salary"]          as? String
        self.requirements   = json["requirements"]    as? String
        self.jobDescription = json["jobDescription"]  as? String
        self.schedule       = json["schedule"]        as? String

        let isRemote = json["remote"] as? Bool ?? false
        let isHybrid = json["hybrid"] as? Bool ?? false
        self.workLocationType = isRemote ? .remote : isHybrid ? .hybrid : .onSite
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
    
}


extension JobListing {
    
    enum SalaryType: String, Codable, CaseIterable {
        
        case yearly   = "Yearly"
        case monthly  = "Monthly"
        case biWeekly = "Bi-Weekly"
        case weekly   = "Weekly"
        case hourly   = "Hourly"
        
        var suffix: String {
            switch self {
            case .yearly:   return "/Year"
            case .monthly:  return "/Month"
            case .biWeekly: return "/Bi-Weekly"
            case .weekly:   return "/Week"
            case .hourly:   return "/Hour"
            }
        }
        
        var aliases: [String] {
            switch self {
            case .yearly:   return ["year", "yearly", "annual", "annually", "yr"]
            case .monthly:  return ["month", "monthly", "mo"]
            case .biWeekly: return ["bi-weekly", "biweekly", "bi weekly", "bi-week", "biweek"]
            case .weekly:   return ["week", "weekly", "wk"]
            case .hourly:   return ["hour", "hourly", "hr", "h"]
            }
        }
        
        static func stringToTypes(_ s: String) -> (String, SalaryType)? {
            guard let slashIndex = s.lastIndex(of: "/") else { return nil }
            
            let salaryPart = String(s[s.startIndex..<slashIndex]).trimmingCharacters(in: .whitespaces)
            let periodPart = String(s[s.index(after: slashIndex)...]).trimmingCharacters(in: .whitespaces).lowercased()
            
            guard !salaryPart.isEmpty, !periodPart.isEmpty else { return nil }
            
            for type in SalaryType.allCases {
                if type.aliases.contains(where: { periodPart.hasPrefix($0) }) {
                    return (salaryPart, type)
                }
            }
            
            return nil
        }
        
        static func TypesToString(_ s: String, _ st: SalaryType) -> String? {
            let trimmed = s.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return nil }
            return "\(trimmed)\(st.suffix)"
        }
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
        realJobListingSample,
        JobListing(
            title: "Unemployment assistance",
            company: "Government",
            jobURL: URL(string: "https://apple.com")!,
            location: "Florida",
            salaryRange: "$1k",
            salaryType: .monthly,
            applicationStatus: .accepted
        ),
        JobListing(
            title: "Swift Software Engineer",
            company: "Apple",
            jobURL: URL(string: "https://apple.com")!,
            location: "Cupertino, California",
            salaryRange: "$150-200k",
            schedule: "Full-Time",
            notes: "REALLY want this job!!!!! Apple Campus is very beautiful.\nAlso 996 work schedule",
            date: makeDate(year: 2026, month: 4, day: 2, hour: 11),
            applicationStatus: .rejected
        ),
        JobListing(
            title: "Junior Backend Developer",
            company: "Microsoft",
            jobURL: URL(string: "https://microsoft.com")!,
            location: "Redmond, Washington",
            salaryRange: "$120-180k",
            schedule: "Full-Time",
            date: makeDate(year: 2026, month: 4, day: 2, hour: 12),
            applicationStatus: .ghosted
        ),
        JobListing(
            title: "Weird Job",
            company: "Local Company",
            jobURL: nil,
            date: makeDate(year: 2026, month: 2, day: 1, hour: 13),
            applicationStatus: .applied
        ),
        JobListing(
            title: "UX Engineer, iOS, Google Search App",
            company: "Google",
            jobURL: URL(string: "https://google.com")!,
            location: "California",
            salaryRange: "Not Provided",
            schedule: "Full-Time",
            date: makeDate(year: 2026, month: 3, day: 15, hour: 11),
            applicationStatus: .rejected
        ),
        JobListing(
            title: "iOS Engineer (Audible)",
            company: "Amazon",
            jobURL: URL(string: "https://amazon.com")!,
            location: "Austin, Texas",
            salaryRange: "$140-180k",
            schedule: "Full-Time",
            date: makeDate(year: 2026, month: 3, day: 15, hour: 12),
            applicationStatus: .ghosted
        ),
        JobListing(
            title: "iOS Frameworks Engineer, Platform Privacy",
            company: "Apple",
            jobURL: URL(string: "https://apple.com")!,
            location: "Cupertino, California",
            salaryRange: "$120-180k",
            schedule: "Full-Time",
            date: makeDate(year: 2026, month: 3, day: 15, hour: 13),
            applicationStatus: .ghosted
        ),
        JobListing(
            title: "Wagie",
            company: "Amazon",
            jobURL: URL(string: "https://amazon.com")!,
            location: "Hell",
            salaryRange: "$12/hr",
            schedule: "Suicidal",
            date: makeDate(year: 2026, month: 1, day: 2, hour: 12),
            applicationStatus: .offerPending
        )
    ]}
    
    static let realJobListingSample = JobListing(
        title: "Software Engineer III, iOS Video",
        company: "Google", jobURL: URL(string: "https://www.google.com/about/careers/applications/jobs/results/129091183585436358-software-engineer-iii-ios-video?q=ios"),
        location: "Mountain View, CA, USA",
        salaryRange: "$147,000-$211,000",
        schedule: "Full Time",
        notes: "N/A",
        requirements: "Minimum qualifications:\n* Bachelor's degree or equivalent practical experience.\n* 2 years of experience with iOS application development.\n* 2 years of experience with software development in one or more programming languages (Swift, Objective-C), or 1 year of experience with an advanced degree.\nPreferred qualifications:\n* Master's degree or PhD in Computer Science or related technical fields.\n* Experience achieving low-latency video streaming experiences at large-scale.\n* Experience with iOS mobile app development, with working on large-scale apps.\n* Experience with audio visual foundations, such as video playback and video composition.\n* Familiarity with video codecs, containers, and processing.",
        jobDescription: "Google's software engineers develop the next-generation technologies that change how billions of users connect, explore, and interact with information and one another. Our products need to handle information at massive scale, and extend well beyond web search. We're looking for engineers who bring fresh ideas from all areas, including information retrieval, distributed computing, large-scale system design, networking and data storage, security, artificial intelligence, natural language processing, UI design and mobile; the list goes on and is growing every day. As a software engineer, you will work on a specific project critical to Google's needs with opportunities to switch teams and projects as you and our fast-paced business grow and evolve. We need our engineers to be versatile, display leadership qualities and be enthusiastic to take on new problems across the full-stack as we continue to push technology forward.\nThe Photos Foundations Client team drives the Google Photos' app infrastructure towards long-term resilience, while advancing Photos' goal in key mobile ecosystems. We work closely with Pixel and original equipment manufacturer (OEM) partners to make Photos an awesome gallery for Android and iOS devices. We incorporate new Android/iOS framework features into Photos. We own mobile video playback infra and help video consumption experiences in Photos. We make sure users can view and edit all types of media in Photos, by supporting new formats and metadata, including HDR, motion photos, live photos, depth, AI provenance (e.g., C2PA), and more.\nThe Platforms and Devices team encompasses Google's various computing software platforms across environments (desktop, mobile, applications), as well as our first party devices and services that combine the best of Google AI, software, and hardware. Teams across this area research, design, and develop new technologies to make our user's interaction with computing faster and more seamless, building innovative experiences for our users around the world.\nThe US base salary range for this full-time position is $147,000-$211,000 + bonus + equity + benefits. Our salary ranges are determined by role, level, and location. Within the range, individual pay is determined by work location and additional factors, including job-related skills, experience, and relevant education or training. Your recruiter can share more about the specific salary range for your preferred location during the hiring process.\nPlease note that the compensation details listed in US role postings reflect the base salary only, and do not include bonus, equity, or benefits. Learn more about __benefits at Google__.\nResponsibilities\n* Design and build features in the Photos iOS app, while collaborating with Product Manager, UX, Quality Assurance, back-end, and other client engineers.\n* Work on Photos iOS video features, including both user-facing video consumption features as well as video infra.\n* Implement support for viewing and playback experiences for iOS native special formats, like live photos.\n* Be part of the AI transformation happening in Google, learning and adopting Photos and Google One AI Developer AI best practices.",
        workLocationType: .hybrid,
        salaryType: .yearly,
        applicationStatus: .applied
    )
}

typealias WorkLocationType = JobListing.WorkLocationType
typealias SalaryType = JobListing.SalaryType
typealias ApplicationStatus = JobListing.ApplicationStatus
