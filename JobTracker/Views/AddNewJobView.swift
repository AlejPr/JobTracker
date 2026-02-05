//
//  AddNewJobView.swift
//  JobTracker
//

import SwiftUI
import SwiftData
import WebKit


struct AddNewJobView: View {

    @State private var listingLink: String = ""
    @State private var jobTitle: String = ""
    @State private var companyName: String = ""
    @State private var location: String = ""
    @State private var workLocationType: WorkLocationType = .onSite
    @State private var salaryRange: String = ""
    @State private var salaryNotListed: Bool = false
    @State private var salaryType: SalaryType = .yearly
    @State private var notes: String = ""

    @State private var autofill: Bool = true
    @State private var saveWebPage: Bool = true
    
    @State private var isEditing: Bool = false
    @State var expandedPickerId: String?
    @State var showTooltip: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let isWide = proxy.size.width >= 900
            ScrollView {
                Group {
                    if isWide {
                        //MARK: - Horizontal Layout
                        HStack(alignment: .top, spacing: 0) {
                            LazyVStack {
                                infoBody
                                    .zIndex(1000)
                                
                                Spacer()
                                
                                AddJobButton(action: addJobButtonPressed)
                                    .padding(.horizontal, 12)
                                    .padding(.top, 70)
                            }
                            .frame(maxWidth: 600)
                            
                            webPreview
                                .padding(.trailing, 24)
                        }
                        
                    } else {
                        //MARK: - Vertical Layout
                        LazyVStack(alignment: .leading, spacing: -10) {
                            infoBody
                                .zIndex(1000)
                            
                            AddJobButton(action: addJobButtonPressed)
                                .padding(.horizontal, 10)
                            
                            webPreview
                                .padding(.bottom, 50)
                        }

                    }
                }
                .id(isWide)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: isWide)
            }
            .background(Color.white)
            .onTapGesture {
                isEditing = false
                expandedPickerId = nil
                showTooltip = false
            }
        }
    }
    
    
    //MARK: - Info
    var infoBody: some View {
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
                                 expandedPickerId: $expandedPickerId,
                                 pickerId: "WorkLocationTypePickerID")
                .frame(minWidth: 140)
                
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
                                 disabled: salaryNotListed,
                                 expandedPickerId: $expandedPickerId,
                                 pickerId: "SalaryRangeTypePickerID")
                .frame(minWidth: 140)
                
                LabeledButton(selected: $salaryNotListed, labelText: "Not Listed")
                    .padding(.bottom, 10)
                                
            }.zIndex(999)
            
            LabeledTextField(header: "Notes", placeHolderText: "Contract Job, 18 months only", axis: .vertical, textFieldText: $notes)
            
            Spacer()
        }
        .padding(24)
        .background(Color.white)
    }
    
    
    //MARK: - Web Preview
    var webPreview: some View {
        VStack(spacing: 8) {
                       
            //TODO: - Check listing link is valid
            HStack {
                LabeledButton(selected: $saveWebPage, labelText: "Save Webpage")
                
                Button { showTooltip.toggle() }
                label: {
                    Image(systemName: "questionmark.circle")
                        .font(Font.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal, -12)
                }
                
            }
            .padding(.top, 8)
            .opacity(listingLink == "" ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: listingLink)
            .zIndex(1000)
            .overlay {
                if showTooltip {
                    GeometryReader { geometry in
                        HelpTooltip()
                            .position(x: 0, y: (geometry.size.height / 2) + 12)
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .trailing)))
                    }
                }
            }

            Color.gray
                .cornerRadius(12)
                .frame(minHeight: 700)
                .padding(.leading, 8)
            //JobListingPreview(urlString: "https://google.com")
                //.frame(minHeight: 200)
                
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    
    private func addJobButtonPressed() {
        return print("tapped!")
    }
    
}


extension AddNewJobView {
    
    
    //MARK: - Text Field
    private struct LabeledTextField: View {
        var header: String
        var placeHolderText: String
        var axis: Axis = .horizontal
        var disabled: Bool = false
        @Binding var textFieldText: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(header)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                
                TextField(" ", text: $textFieldText, axis: axis)
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
    
    
    //MARK: - Buttons
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
    
    
    private struct AddJobButton: View {
        let action: () -> Void
        let buttonSidePadding: CGFloat = 15
        let containerHeight: CGFloat = 90
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.leading, 10)
                    
                    Text("Add Job")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.trailing, 20)
                }
                .foregroundColor(.white)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, buttonSidePadding)
            .frame(height: containerHeight)
            .transition(.move(edge: .bottom))
        }

    }
    
    
    //MARK: - ToolTip
    struct HelpTooltip: View {
        let message = "Saves an offline copy of the web page.\nIf disabled, saves a screenshot instead."
        
        var body: some View {
            HStack(spacing: 0) {
                // Tooltip content
                Text(message)
                    .font(.system(size: 12))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 230, height: 34, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(sideBarColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(sideBarDividerColor, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
                
                // Arrow pointing right (to the button)
                ZStack {
                    ArrowRight()
                        .fill(sideBarColor)
                        .frame(width: 8, height: 12)
                    
                    ArrowRightStroke()
                        .stroke(sideBarDividerColor, lineWidth: 1)
                        .frame(width: 8, height: 12)
                }
                .offset(x: -1, y: -8)
            }
        }
    }

    struct ArrowRight: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            return path
        }
    }

    struct ArrowRightStroke: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            // Only stroke the top and bottom edges, not the left
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            return path
        }
    }
    
}




#Preview {
    
    AddNewJobView()
        .frame(width: 900, height: 800)
    
}

