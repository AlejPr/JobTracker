//
//  JobEntryView.swift
//  JobTracker
//

import SwiftUI
import SwiftData
import Combine
import WebKit


struct JobEntryView: View {

    @StateObject private var viewModel = ViewModel()
    let geometryProxy: GeometryProxy
    
    private var isCompact: Bool { geometryProxy.size.width < 900 }
    
    var body: some View {
        ScrollView {
            
            Group {
                if !isCompact { horizontalLayout }
                else { verticalLayout }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: isCompact)
        }
        .background(Color.white)
        .onTapGesture { viewModel.dismissOverlays() }
    }
    
    
    private var horizontalLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            LazyVStack {
                infoBody
                    .zIndex(1000)
                
                Spacer()
                
                AddJobButton(
                    isEnabled: viewModel.canSaveJob,
                    action: viewModel.addJobButtonPressed
                )
                .padding(.horizontal, 12)
                .padding(.top, 70)
            }
            .frame(maxWidth: 600)
            
            webPreview
                .padding(.trailing, 24)
        }
    }
    
    
    private var verticalLayout: some View {
        LazyVStack(alignment: .leading, spacing: -10) {
            infoBody
                .zIndex(1000)
            
            webPreview
                .padding(.bottom, 50)
        }
    }
    
    
    //MARK: - Info
    var infoBody: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Listing Link
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Listing Link")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    LabeledButton(
                        selected: $viewModel.autofill,
                        labelText: "Autofill"
                    )
                }
                
                TextField(" ", text: $viewModel.listingLink)
                    .textFieldStyle(CustomTextFieldStyle())
                    .modifier(TextFieldPlaceholderStyle(
                        showPlaceHolder: viewModel.listingLink.isEmpty,
                        placeholder: "https://example.com/job-listing",
                        textColor: Color.gray
                    ))
                    .background(sideBarColor)
            }
            
            LabeledTextField(
                header: "Job Title",
                placeHolderText: "macOS Developer",
                required: true,
                textFieldText: $viewModel.jobTitle
            )
            
            LabeledTextField(
                header: "Company Name",
                placeHolderText: "Apple Inc.",
                required: true,
                textFieldText: $viewModel.companyName
            )
            
            HStack(alignment: .bottom, spacing: 20) {
                LabeledTextField(
                    header: "Location",
                    placeHolderText: "Cupertino, CA",
                    textFieldText: $viewModel.location
                )
                
                CustomPickerView(
                    options: WorkLocationType.allCases,
                    displayName: { $0.rawValue },
                    selection: $viewModel.workLocationType,
                    backgroundColor: sideBarColor,
                    borderColor: sideBarDividerColor,
                    textColor: Color.black,
                    padding: EdgeInsets(top: 11, leading: 14, bottom: 11, trailing: 14),
                    expandedPickerId: $viewModel.expandedPickerId,
                    pickerId: "WorkLocationTypePickerID"
                )
                .frame(minWidth: 140)
            }
            .zIndex(1000)
            
            // Salary Range
            HStack(alignment: .bottom, spacing: 20) {
                LabeledTextField(
                    header: "Salary Range",
                    placeHolderText: "$120k - 150k",
                    disabled: viewModel.salaryNotListed,
                    textFieldText: $viewModel.salaryRange
                )
                
                CustomPickerView(
                    options: SalaryType.allCases,
                    displayName: { $0.rawValue },
                    selection: $viewModel.salaryType,
                    backgroundColor: sideBarColor,
                    borderColor: sideBarDividerColor,
                    textColor: Color.black,
                    padding: EdgeInsets(top: 11, leading: 14, bottom: 11, trailing: 14),
                    disabled: viewModel.salaryNotListed,
                    expandedPickerId: $viewModel.expandedPickerId,
                    pickerId: "SalaryRangeTypePickerID"
                )
                .frame(minWidth: 140)
                
                LabeledButton(
                    selected: $viewModel.salaryNotListed,
                    labelText: "Not Listed"
                )
                .padding(.bottom, 10)
            }
            .zIndex(999)
            
            LabeledTextField(
                header: "Notes",
                placeHolderText: "Contract Job, 18 months only",
                axis: .vertical,
                textFieldText: $viewModel.notes
            )
            
            Spacer()
        }
        .padding(24)
        .background(Color.white)
    }
    
    
    //MARK: - Web Preview
    var webPreview: some View {
        VStack(spacing: 8) {
            
            HStack {
                LabeledButton(
                    selected: $viewModel.saveWebPage,
                    labelText: "Save Webpage"
                )
                
                Button {
                    viewModel.toggleTooltip()
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(Font.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal, -12)
                }
            }
            .padding(.top, 8)
            .opacity(viewModel.listingLink.isEmpty ? 0 : 1)
            .zIndex(1000)
            .overlay {
                if viewModel.showTooltip {
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
            // JobListingPreview(urlString: viewModel.listingLink)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    
    private func addJobButtonPressed() {
        return print("tapped!")
    }
    
}


//MARK: - View Model
extension JobEntryView {
    
    @MainActor
    final class ViewModel: ObservableObject {
                
        @Published var listingLink: String = ""
        @Published var jobTitle: String = ""
        @Published var companyName: String = ""
        @Published var location: String = ""
        @Published var workLocationType: WorkLocationType = .onSite
        @Published var salaryRange: String = ""
        @Published var salaryNotListed: Bool = false
        @Published var salaryType: SalaryType = .yearly
        @Published var notes: String = ""
        
        @Published var autofill: Bool = true
        @Published var saveWebPage: Bool = true
        
        @Published var expandedPickerId: String?
        @Published var showTooltip: Bool = false
        
        var canSaveJob: Bool { !jobTitle.isEmpty && !companyName.isEmpty }
                
        func addJobButtonPressed() {
            guard canSaveJob else { return }
            print("Saving job: \(jobTitle) at \(companyName)")
        }
        
        func toggleTooltip() {
            showTooltip.toggle()
        }
        
        func dismissOverlays() {
            expandedPickerId = nil
            showTooltip = false
        }
    }
    
}


//MARK: - Subviews
extension JobEntryView {
    
    
    //MARK: - Text Field
    private struct LabeledTextField: View {
        let header: String
        let placeHolderText: String
        var axis: Axis = .horizontal
        var disabled: Bool = false
        var required: Bool = false
        @Binding var textFieldText: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    Text(header)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    if required {
                        Text("*")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                
                TextField(" ", text: $textFieldText, axis: axis)
                    .textFieldStyle(CustomTextFieldStyle())
                    .modifier(TextFieldPlaceholderStyle(
                        showPlaceHolder: textFieldText.isEmpty,
                        placeholder: placeHolderText,
                        textColor: Color.gray
                    ))
                    .background(sideBarColor)
                    .disabled(disabled)
                    .overlay {
                        if disabled {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
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
        let labelText: String
        
        var body: some View {
            HStack {
                Button { selected.toggle() }
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
                
                Text(labelText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
        }
    }
    
    
    private struct AddJobButton: View {
        let isEnabled: Bool
        let action: () -> Void
        
        var body: some View {
            LargeStylizedButton(
                action: action,
                imageName: "plus",
                title: "Add Job",
                isVisible: true,
                disabled: !isEnabled
            )
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
                    .foregroundColor(.black)
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


//MARK: - Preview
#Preview {
    
    GeometryReader { proxy in
        JobEntryView(geometryProxy: proxy)
    }.frame(width: 900, height: 800)
    
}

