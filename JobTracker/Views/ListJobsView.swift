//
//  ListJobsView.swift
//  JobTracker
//

import SwiftUI
import SwiftData

struct ListJobsView: View {
    
    @Query(sort: \JobListing.timeStampApplied, order: .reverse) private var jobListings: [JobListing]
    @Environment(\.appendNavigationPath) var appendToNavigationStack
    
    var body: some View {
        if !jobListings.isEmpty {
            contentView
        }
        else {
            ZStack {
                Color.blue
                Text("No Listings!")
                    .foregroundStyle(.black)
            }
        }
    }
    
    var contentView: some View {
        ScrollView {
            
            Spacer()
                .frame(height: 20)
            
            let sortedListingGroups = groupJobListingsByDate(jobListings)
            ForEach(sortedListingGroups, id: \.self) { group in
                JobListingGroup(
                    jobListings: group,
                    jobListingTapped: { appendToNavigationStack(.jobListing($0), true) }
                )
                .padding(.bottom, 20)
            }
            
            Spacer()
                .frame(height: 80)
            
        }.background(Color.white)
    }
    
    private func groupJobListingsByDate(_ listings:[JobListing]) -> [[JobListing]] {
        var today = [JobListing]()
        var thisWeek = [JobListing]()
        var thisMonth = [JobListing]()
        var older = [[JobListing]]()
        var currentGroup = [JobListing]()
        
        for listing in listings {
            switch DateGroupInterval.classify(listing.timeStampApplied) {
            case .today: today.append(listing)
            case .thisWeek: thisWeek.append(listing)
            case .thisMonth: thisMonth.append(listing)
            case .older:
                if let last = currentGroup.last,
                   !Calendar.current.isDate(last.timeStampApplied, inSameDayAs: listing.timeStampApplied) {
                    older.append(currentGroup)
                    currentGroup = []
                }
                currentGroup.append(listing)
            }
        }

        if !currentGroup.isEmpty { older.append(currentGroup) }

        return [today, thisWeek, thisMonth].filter { !$0.isEmpty } + older
    }
    
    
    enum DateGroupInterval: String {
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case older
        
        static func classify(_ date: Date, relativeTo now: Date = Date()) -> DateGroupInterval {
            let calendar = Calendar.current
            if calendar.isDateInToday(date)              { return .today }
            if date >= now.addingTimeInterval(-604_800)  { return .thisWeek }
            if date >= now.addingTimeInterval(-2_592_000) { return .thisMonth }
            return .older
        }
    }
    
    
}


//MARK: - Section
fileprivate struct JobListingGroup: View {
    
    var jobListings: [JobListing]
    var jobListingTapped: (JobListing) -> Void
    var dgClass: dgInterval { dgInterval.classify(jobListings.first!.timeStampApplied) }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            Text(dgClass == .older ? headerDate : dgClass.rawValue)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 75/255, green: 85/255, blue: 99/255))
                .padding(.leading, 30)
            
            ForEach(jobListings, id: \.self) { jobListing in
                JobListingView(
                    jobListing: jobListing,
                    tapped: jobListingTapped
                )
            }
        }
        
    }
    
    private var headerDate: String {
        return dateFormatter.string(from: jobListings.first!.timeStampApplied)
    }
    
}


//MARK: - Rows
fileprivate struct JobListingView: View {
    
    var jobListing: JobListing
    var tapped: (JobListing) -> Void
    
    var body: some View {
        let attributes = calculateAttributes()
        let showAttributes = !attributes.isEmpty
        
        Button { tapped(jobListing) }
        label: {
            HStack {
                
                //Image
                let split = jobListing.company.split(separator: " ")
                let companyAbbreviation: String = {
                    if split.count > 1 { return "\(split[0].prefix(1).uppercased() + split[1].prefix(1).uppercased())" }
                    return jobListing.company.prefix(2).uppercased()
                }()
                
                Text(companyAbbreviation)
                    .font(Font.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 45, height: 45)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(5)
                    .padding(.leading, 20)
                    .padding(.bottom, showAttributes ? 30 : 0)
                    .padding(.vertical, showAttributes ? 0 : 15)
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            //Title Labels
                            Text("\(jobListing.title)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                            Text("\(jobListing.company)")
                                .font(.title3)
                                .foregroundStyle(.black)
                        }
                        .padding(.vertical, showAttributes ? 0 : 15)
                        
                    }
                    
                    if showAttributes {
                        HStack { jobAttributes(attributes) }
                        .padding(.top, 5)
                    }
                    
                }
                .padding(.leading, 10)
                
                Spacer()
                
                
                VStack(alignment: .trailing) {
                    Text(jobListing.applicationStatus.rawValue)
                        .fontWeight(.light)
                        .foregroundStyle(.black)
                        .padding(5)
                        .background(jobListing.applicationStatus.color)
                        .cornerRadius(5)
                    
                    Spacer()
                    
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.blue)
                        .font(Font.system(size: 20, weight: .medium))
                        .padding(.trailing, 10)
                }
                .padding([.leading, .trailing], 10)
                .padding(.bottom, 10)
                
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(sideBarDividerColor, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .shadow(color: Color.black.opacity(0.1), radius: 5)
        }
        
    }

    
    private func calculateAttributes() -> [(String, Color)] {
        var items: [(String, Color)] = [jobListing.schedule, jobListing.location]
            .compactMap { $0 }
            .map { ($0, Color.gray.opacity(0.1)) }
        if let pay = jobListing.salaryRange {
            items.append((formatSalaryRange(pay.replacingOccurrences(of: "/Year", with: ""), jobListing.salaryType ?? .yearly), Color.blue.opacity(0.2)))
        }
        return items
    }
    
    
    private func jobAttributes(_ attributes: [(String, Color)]) -> some View {
        return ForEach(attributes.indices, id: \.self) { index in
            let value = attributes[index]
            Text(value.0)
                .fontWeight(.light)
                .foregroundStyle(.black)
                .padding(5)
                .background(value.1)
                .cornerRadius(5)
        }
    }
    
    
    private func formatSalaryRange(_ range: String,_ salaryType: SalaryType) -> String {
        switch salaryType {
        case .yearly: return range
        case .monthly: return range + " / mo"
        case .biWeekly: return range + " / bi-wkly"
        case .weekly: return range + " / wk"
        case .hourly: return range + " / hr"
        }
    }
    
    
}



//MARK: - Stupid date formatter
fileprivate class CustomDateFormatter: DateFormatter, @unchecked Sendable {
    
    override init() {
        super.init()
        self.setLocalizedDateFormatFromTemplate("MMMMd")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func string(from date: Date) -> String {
        return super.string(from: date) + "\(daySuffix(with: date))"
    }
    
    func daySuffix(with date: Date) -> String {
        let dayOfMonth = Calendar.current.dateComponents([.day], from: date).day!
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
}

fileprivate let dateFormatter = CustomDateFormatter()
fileprivate typealias dgInterval = ListJobsView.DateGroupInterval

fileprivate struct PreviewStruct: View {
    let empty: Bool
    
    var body: some View {
        if !empty {
            ListJobsView()
                .sampleContainer()
                .frame(width: 700, height: 500)
        }
        else {
            ListJobsView()
                .modelContainer(for: [JobListing.self])
        }
    }
}


#Preview {
    PreviewStruct(empty: false)
}

#Preview("No Listings") {
    PreviewStruct(empty: true)
}

