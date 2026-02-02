//
//  ListJobsView.swift
//  JobTracker
//

import SwiftUI
import SwiftData

struct ListJobsView: View {
    
    var jobListings = sampleData

    var body: some View {
        
        ZStack {
            Color.white
            
            ScrollView {
                VStack {
                    VStack {
                        ForEach(sampleData) { jobListing in
                            JobListingView(jobListing: jobListing)
                        }
                    }.padding(.bottom, 25)
                    
                    ForEach(sampleData) { jobListing in
                        JobListingView(jobListing: jobListing)
                    }
                    
                    Spacer()
                }.padding(.top, 25)
            }

        }
        
    }
    
}




fileprivate struct JobListingView: View {
    
    var jobListing: JobListing
    
    var body: some View {
        
        HStack {
            VStack {
                Text("\(jobListing.company.prefix(1))")
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

    private func jobAttributes() -> some View {
        let items: [String] = [jobListing.schedule, jobListing.location, jobListing.payRange]
            .compactMap { $0 }

        return ForEach(items, id: \.self) { value in
            Text(value)
                .fontWeight(.light)
                .foregroundStyle(.black)
                .padding(5)
                .background(value == jobListing.payRange ?  Color.blue.opacity(0.2) : Color.gray.opacity(0.1) )
                .cornerRadius(5)
        }
    }
}


#Preview {
    
    ListJobsView()
        .frame(width: 700, height: 500)
    
}


