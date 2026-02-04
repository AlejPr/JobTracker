//
//  AddNewJobView.swift
//  JobTracker
//

import SwiftUI
import SwiftData

struct AddNewJobView: View {
    
    var body: some View {
        ListingInfoView()
    }
    
}


struct ListingInfoView: View {

    @State private var listingLink: String = ""
    @State private var jobTitle: String = ""
    @State private var companyName: String = ""
    @State private var autofill: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text("Listing Link")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button { autofill.toggle() }
                    label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(autofill ? Color.blue : Color.gray, lineWidth: 2)
                                .frame(width: 16, height: 16)
                            
                            if autofill {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue)
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                    .padding(.trailing, -10)
                    
                    Text("Autofill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }
                
                TextField(" ", text: $listingLink)
                    .textFieldStyle(CustomTextFieldStyle())
                    .modifier(TextFieldPlaceholderStyle(showPlaceHolder: listingLink == "", placeholder: "https://example.com/job-listing", textColor: Color.gray))
                    .background(sideBarColor)
            }
            
            LabeledTextField(header: "Job Title", placeHolderText: "macOS Developer", textFieldText: $jobTitle)
            LabeledTextField(header: "Company Name", placeHolderText: "Apple Inc.", textFieldText: $companyName)
            
            Spacer()
            
        }
        .padding(24)
        .background(Color.white)
    }
    
    private struct LabeledTextField: View {
        var header: String
        var placeHolderText: String
        @Binding var textFieldText: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(header)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                
                TextField(" ", text: $textFieldText)
                    .textFieldStyle(CustomTextFieldStyle())
                    .modifier(TextFieldPlaceholderStyle(showPlaceHolder: textFieldText == "", placeholder: placeHolderText, textColor: Color.gray))
                    .background(sideBarColor)

            }
        }
        
    }
    
    
    private struct CustomTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .foregroundStyle(.black)
                .textFieldStyle(.plain)
                .padding(12)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(sideBarDividerColor, lineWidth: 1)
                )
        }
    }
    
}




#Preview {
    
    HStack(spacing: 50) {
        ListingInfoView()
            .frame(width: 450, height: 700)
    }
}
