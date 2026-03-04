//
//  JobDetailView.swift
//  JobTracker
//

import SwiftUI


struct JobDetailView: View {
    
    var jobListing: JobListing
    
    var body: some View {
        infoView
    }
    
    var infoView: some View {
        VStack(spacing: 10) {
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
                    .padding(.leading, 20)
                
                
                LabeledAttribute(title: jobListing.title, text: jobListing.company,
                                 titleFont: .largeTitle.bold(), titleStyle: .black,
                                 textFont: .title)
                .padding(.leading, 20)
                .padding(.trailing, 10)
                
            }
            .padding(.bottom, 15)
            
            HStack() {
                
                VStack(alignment: .leading, spacing: 15) {
                    LabeledAttribute(title: "Applied", text: "Jan 10, 2026")
                    
                    LabeledAttribute(title: "Location", text: jobListing.location ?? "Remote (US)")
                }
                Spacer()
                
                VStack(alignment: .leading, spacing: 15) {
                    LabeledAttribute(title: "Salary Range", text: jobListing.payRange ?? "$120k - $150k")


                    LabeledAttribute(title: "Schedule", text: jobListing.schedule ?? "Full-Time")
                }
                .padding(.trailing, 25)
            }
            .padding(.horizontal, 25)

            
        }
        .padding(20)
        .padding(.trailing, 25)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 5)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(sideBarDividerColor, lineWidth: 2)
        }
        .frame(width: 500)
        
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
                    .lineLimit(1)
                Text(text)
                    .font(textFont)
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }
        }
    }
    
    
}


#Preview {
    ZStack {
        sideBarColor
        
        JobDetailView(jobListing: JobListing.sampleData[1])
            .frame(width: 700, height: 500)
    }
}
