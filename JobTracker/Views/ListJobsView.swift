//
//  ListJobsView.swift
//  JobTracker
//

import SwiftUI
import SwiftData

struct ListJobsView: View {
    
    @Query(sort: \JobListing.timeStampApplied, order: .reverse) private var jobListings: [JobListing]
    @Environment(\.appendNavigationPath) var appendToNavigationStack
    @Environment(DashboardTopBarViewModel.self) var dashboardViewModel
    
    private var filteredListings: [JobListing] {
        let searchText = dashboardViewModel.searchText.trimmingCharacters(in: .whitespaces)
        
        if searchText.isEmpty {
            return jobListings
        }
        
        return jobListings.filter { listing in
            listing.title.localizedCaseInsensitiveContains(searchText) ||
            listing.company.localizedCaseInsensitiveContains(searchText) ||
            listing.jobDescription?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
    var body: some View {
        if !filteredListings.isEmpty {
            contentView
        }
        else if jobListings.isEmpty {
            ZStack {
                Color.blue
                Text("No Listings!")
                    .foregroundStyle(.black)
            }
        }
        else {
            // Search returned no results
            ZStack {
                Color.white
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.gray)
                    Text("No results for \"\(dashboardViewModel.searchText)\"")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
    
    var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: []) {
                
                Color.clear.frame(height: 20)
                
                let sortedListingGroups = groupJobListingsByDate(filteredListings)
                ForEach(sortedListingGroups.indices, id: \.self) { index in
                    JobListingGroup(
                        jobListings: sortedListingGroups[index],
                        jobListingTapped: { listing in appendToNavigationStack(.jobListing(listing), true) }
                    )
                    .padding(.bottom, 20)
                }
                
                Color.clear.frame(height: 80)
            }
        }
        .background(Color.white)
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
    
    let jobListings: [JobListing]
    let jobListingTapped: (JobListing) -> Void
    
    private var dgClass: dgInterval { dgInterval.classify(jobListings.first!.timeStampApplied) }
    private var headertext: String { dgClass == .older ? headerDate : dgClass.rawValue }
    private var headerDate: String { dateFormatter.string(from: jobListings.first!.timeStampApplied) }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            Text(headertext + " - \(jobListings.count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 75/255, green: 85/255, blue: 99/255))
                .padding(.leading, 30)
            
            ForEach(jobListings, id: \.id) { jobListing in
                JobListingView(
                    jobListing: jobListing,
                    tapped: jobListingTapped
                )
            }
        }
    }
    
}


//MARK: - Rows
fileprivate struct JobListingView: View {
    
    let jobListing: JobListing
    let tapped: (JobListing) -> Void
    
    private var attributes: [(String, Color)] { calculateAttributes() }
    private var showAttributes: Bool { !attributes.isEmpty }
    private var companyAbbreviation: String {
        let split = jobListing.company.split(separator: " ")
        if split.count > 1 { 
            return "\(split[0].prefix(1).uppercased() + split[1].prefix(1).uppercased())" 
        }
        return jobListing.company.prefix(2).uppercased()
    }
    
    var body: some View {
        Button { tapped(jobListing) }
        label: {
            HStack {
                
                //Image
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
                .environment(DashboardTopBarViewModel())
                .frame(width: 700, height: 500)
        }
        else {
            ListJobsView()
                .modelContainer(for: [JobListing.self])
                .environment(DashboardTopBarViewModel())
        }
    }
}


#Preview {
    PreviewStruct(empty: false)
}

#Preview("No Listings") {
    PreviewStruct(empty: true)
}

