//
//  ListJobsView.swift
//  JobTracker
//

import SwiftUI
import SwiftData

struct ListJobsView: View {
    
    @Query(sort: \JobListing.timeStampApplied, order: .reverse) private var jobListings: [JobListing]
    
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
            ForEach(sortedListingGroups.indices, id: \.self) { groupIndex in
                JobListingGroup(jobListings: sortedListingGroups[groupIndex])
                    .padding(.bottom, 20)
            }
            
            Spacer()
                .frame(height: 80)
            
        }.background(Color.white)
    }
    
    private func groupJobListingsByDate(_ listings:[JobListing]) -> [[JobListing]] {
        let currentDate = Date()
        var res = [[JobListing]]()
        var curr = [JobListing]()
        
        for listing in listings {
            //Last 7 days
            if listing.timeStampApplied >= currentDate.addingTimeInterval(-604800) { curr.append(listing) }
            
            else {
                if let last = curr.last, !Calendar.current.isDate(last.timeStampApplied, inSameDayAs: listing.timeStampApplied) {
                    res.append(curr)
                    curr = []
                }
                
                curr.append(listing)
            }
        }
        
        if !curr.isEmpty { res.append(curr) }
        //res.append(curr)
        return res
    }
    
}


//MARK: - Section
fileprivate struct JobListingGroup: View {
    
    var jobListings: [JobListing]
    var thisWeek: Bool {
        jobListings.first!.timeStampApplied >= Date().addingTimeInterval(-604800)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            Text(thisWeek ? "This Week" : headerDate )
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 75/255, green: 85/255, blue: 99/255))
                .padding(.leading, 30)
            
            ForEach(jobListings) { jobListing in
                JobListingView(jobListing: jobListing)
            }
        }
        
    }
    
    private var headerDate: String {
        return dateFormatter.string(from: jobListings.first!.timeStampApplied)
    }
    
}


//MARK: - Individual Rows
fileprivate struct JobListingView: View {
    
    var jobListing: JobListing
    
    var body: some View {
        
        Button { print("\(jobListing.title), \(jobListing.company)") }
        label: {
            HStack {
                VStack {
                    Text("\(jobListing.company.prefix(1))")
                        .font(Font.system(size: 16, weight: .medium))
                        .frame(width: 45, height: 45)
                        .background(Color.blue)
                        .cornerRadius(5)
                        .padding(.leading, 20)
                        .padding(.bottom, 30)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text("\(jobListing.title)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                    Text("\(jobListing.company)")
                        .font(.title3)
                        .foregroundStyle(.black)
                    
                    HStack {
                        jobAttributes()
                    }
                    .padding(.top, 5)
                    
                }
                .padding(.leading, 10)
                
                Spacer()
                
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

    private func jobAttributes() -> some View {
        let items: [String] = [jobListing.schedule, jobListing.location, jobListing.payRange]
            .compactMap { $0 }

        return ForEach(items, id: \.self) { value in
            if !value.isEmpty {
                Text(value)
                    .fontWeight(.light)
                    .foregroundStyle(.black)
                    .padding(5)
                    .background(value == jobListing.payRange ?  Color.blue.opacity(0.2) : Color.gray.opacity(0.1) )
                    .cornerRadius(5)
            } else { Color.clear }
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


#Preview {
    ListJobsView()
        .sampleContainer()
        .frame(width: 500, height: 500)
}

#Preview("No Listings") {
    ListJobsView()
        .modelContainer(for: [JobListing.self])
}
