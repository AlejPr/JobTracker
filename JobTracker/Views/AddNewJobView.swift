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
    @State private var location: String = ""
    @State private var workLocationType: WorkLocationType = .onSite
    @State private var salaryRange: String = ""
    @State private var salaryNotListed: Bool = false
    @State private var salaryType: SalaryType = .yearly
    @State private var notes: String = ""
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        InfoBody
            .onTapGesture { isEditing = false }
    }
    
    
    var InfoBody: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            //Listing Link
            VStack(alignment: .leading, spacing: 8) {

                HStack {
                    Text("Listing Link")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    LabeledButton(selected: $autofill, labelText: "Autofill")
                }
                
                TextField(" ", text: $listingLink)
                    .textFieldStyle(CustomTextFieldStyle())
                    .modifier(TextFieldPlaceholderStyle(showPlaceHolder: listingLink == "", placeholder: "https://example.com/job-listing", textColor: Color.gray))
                    .background(sideBarColor)
            }
            
            LabeledTextField(header: "Job Title", placeHolderText: "macOS Developer", textFieldText: $jobTitle)
            LabeledTextField(header: "Company Name", placeHolderText: "Apple Inc.", textFieldText: $companyName)
            
            HStack(alignment: .bottom, spacing: 20) {
                LabeledTextField(header: "Location", placeHolderText: "Cupertino, CA", textFieldText: $location)
                
                CustomPickerView(options: WorkLocationType.allCases,
                                 displayName: { $0.rawValue },
                                 selection: $workLocationType,
                                 backgroundColor: sideBarColor,
                                 borderColor: sideBarDividerColor,
                                 textColor: Color.black,
                                 padding: EdgeInsets(top: 11, leading: 14, bottom: 11, trailing: 14),
                ).frame(minWidth: 120, maxWidth: 400)
                
            }.zIndex(1000)
            
            //Salary Range
            HStack(alignment: .bottom, spacing: 20) {
                LabeledTextField(header: "Salary Range", placeHolderText: "$120k - 150k", disabled: salaryNotListed, textFieldText: $salaryRange)
                
                CustomPickerView(options: SalaryType.allCases,
                                 displayName: { $0.rawValue },
                                 selection: $salaryType,
                                 backgroundColor: sideBarColor,
                                 borderColor: sideBarDividerColor,
                                 textColor: Color.black,
                                 padding: EdgeInsets(top: 11, leading: 14, bottom: 11, trailing: 14),
                                 disabled: salaryNotListed
                ).frame(minWidth: 120, maxWidth: 400)
                
                LabeledButton(selected: $salaryNotListed, labelText: "Not Listed")
                    .padding(.bottom, 10)
                                
            }.zIndex(999)
            
            Spacer()
        }
        .padding(24)
        .background(Color.white)
    }
    
    private struct LabeledTextField: View {
        var header: String
        var placeHolderText: String
        var disabled: Bool = false
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
                    .disabled(disabled)
                    .overlay {
                        if disabled {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray)
                                .opacity(0.1)
                        }
                    }
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
    
    
    private struct LabeledButton: View {
        
        @Binding var selected: Bool
        var labelText: String
        
        var body: some View {
            HStack {
                Button { self.selected.toggle() }
                
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(selected ? Color.blue : Color.gray, lineWidth: 2)
                            .frame(width: 16, height: 16)
                        
                        if selected {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .padding(.horizontal, -10)
                .background(Color.clear)
                
                Text("\(labelText)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
        }
    }
    
}




#Preview {
    
    HStack(spacing: 50) {
        ListingInfoView()
            .frame(width: 450, height: 700)
    }
}




