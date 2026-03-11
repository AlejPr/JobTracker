//
//  JobDetailView.swift
//  JobTracker
//

import SwiftUI


struct JobDetailView: View {
    
    @State var listingString: String = ""
    var jobListing: JobListing
    let geometryProxy: GeometryProxy
    
    private var isCompact: Bool { geometryProxy.size.width < 900 }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: jobListing.timeStampApplied)
    }
    
    var body: some View {
        ScrollView {
            
            Group {
                if isCompact { verticalLayout }
                else { horizontalLayout }
            }
            //.frame(minHeight: geometryProxy.size.height - 70)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: isCompact)
        }
        .background(Color.white)
    }
    
    
    var horizontalLayout: some View {
        HStack(alignment: .top) {
            infoView
                .frame(minWidth: 300)
                .padding(25)
            
        }
    }
    
    
    var verticalLayout: some View {
        VStack(spacing: 20) {
            infoView
                .frame(minWidth: 300)
                .padding([.horizontal, .top], 30)

        }
        
    }
    
    
    var infoView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                let split = jobListing.company.split(separator: " ")
                let companyAbbreviation: String = {
                    if split.count > 1 { return "\(split[0].prefix(1).uppercased() + split[1].prefix(1).uppercased())" }
                    return jobListing.company.prefix(2).uppercased()
                }()
                
                Text(companyAbbreviation)
                    .font(Font.system(size: 30, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 80, height: 80)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                
                LabeledAttribute(title: jobListing.title, text: jobListing.company,
                                 titleFont: .largeTitle.bold(), titleStyle: .black,
                                 textFont: .title)
                .padding(.leading, 20)
                
            }
            .padding(.bottom, 15)
            
            HStack() {
                VStack(alignment: .leading, spacing: 15) {
                    LabeledAttribute(title: "Applied", text: formattedDate)
                    
                    LabeledAttribute(title: "Location", text: jobListing.location ?? "Not Provided")
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 15) {
                    LabeledAttribute(
                        title: "Salary Range",
                        text: {
                            guard let pay = jobListing.payRange else { return "Not Provided" }
                            if let salaryType = jobListing.salaryType {
                                return "\(pay) (\(salaryType.rawValue))"
                            }
                            return pay
                        }()
                    )
                    
                    LabeledAttribute(
                        title: "Schedule",
                        text: {
                            var parts: [String] = []
                            if let schedule = jobListing.schedule { parts.append(schedule) }
                            if let workType = jobListing.workLocationType { parts.append(workType.rawValue) }
                            return parts.isEmpty ? "Not Provided" : parts.joined(separator: " · ")
                        }()
                    )
                }
                
                Spacer()
            }
            
            if let notes = jobListing.notes {
                LabeledAttribute(title: "Notes", text: notes)
                    .padding(.top, 10)
                    .padding(.trailing, -35)
            }
            
        }
        .padding(.horizontal, 25)
        .padding(20)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 3)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(sideBarDividerColor, lineWidth: 2)
        }
    }
    
    
    private struct LabeledAttribute: View {
        let title: String
        let text: String
        var titleFont: Font = .title2
        var titleStyle: Color = Color.black.opacity(0.7)
        var textFont: Font = .title2.weight(.medium)
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(titleFont)
                    .foregroundStyle(titleStyle)
                    .lineLimit(title.count > 45 ? 2 : 1)
                    .minimumScaleFactor(0.65)
                    .scaleEffect(title.count > 45 ? 0.8 : 1, anchor: .leading)
                Text(text)
                    .font(textFont)
                    .foregroundStyle(.black)
                    //.lineLimit(1)
            }
        }
    }
    
    
}


#Preview {
    GeometryReader { proxy in
        JobDetailView(jobListing: JobListing.sampleData[1], geometryProxy: proxy)
    }
    .frame(width: 900, height: 700)
}
