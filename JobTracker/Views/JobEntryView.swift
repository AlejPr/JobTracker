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
    @StateObject private var webPageSnapShotViewModel = WebpageSnapshotView.ViewModel()
    
    @Environment(SwiftDataContainer.self) private var dataContainer
    @Environment(\.topbarViewModel) var tbVM
    @Environment(\.customDismiss) var dismiss
        
    let geometryProxy: GeometryProxy
    
    private var isCompact: Bool { geometryProxy.size.width < 900 }
    
    
    var body: some View {
        ScrollView {
            
            Group {
                if !isCompact { horizontalLayout }
                else { verticalLayout }
            }
            .frame(minHeight: geometryProxy.size.height - 70)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: isCompact)
        }
        .background(Color.white)
        .onTapGesture { viewModel.dismissOverlays() }
        .onAppear { tbVM.entryViewAddJobButtonEnabled = false }
        .onChange(of: tbVM.entryViewAddJobButtonPressed) { _, newValue in addJobButtonPressed(newValue) }
    }
    
    
    private var horizontalLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            if !viewModel.webViewIsExpanded {
                LazyVStack { infoBody }
                    .frame(maxWidth: 600)
            }
            
            webPreview
                .padding(.leading, viewModel.webViewIsExpanded ? 24 : 0)
                .padding(.trailing, 24)
                .padding(.bottom, 50)
        }
    }
    
    
    private var verticalLayout: some View {
        LazyVStack(alignment: .leading, spacing: -20) {
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
                    
                    let isEnabled = viewModel.autofillButtonDisabled ? false : isValidUrl(url: viewModel.listingLink)
                    Button { viewModel.attemptAutofill(with: webPageSnapShotViewModel) }
                    label: {
                        Text("Autofill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.white)
                            .frame(height: 10)
                            .padding(10)
                            .padding(.bottom, 2)
                            .background(isEnabled ? Color.accentColor : Color.gray.opacity(0.8))
                            .cornerRadius(5)
                    }
                    .disabled(!isEnabled)
                    .buttonStyle(PressedOpacityButtonStyle())
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
            .onChange(of: viewModel.jobTitle) { _, _ in
                checkCanAddJob()
            }
            
            HStack(alignment: .bottom, spacing: 20) {
                LabeledTextField(
                    header: "Company Name",
                    placeHolderText: "Apple Inc.",
                    required: true,
                    textFieldText: $viewModel.companyName
                )
                .onChange(of: viewModel.companyName) { _, _ in
                    checkCanAddJob()
                }
                
                CustomPickerView(
                    options: [ApplicationStatus.applied, ApplicationStatus.saved, ApplicationStatus.emailed],
                    displayName: { $0.rawValue },
                    selection: $viewModel.applicationStatus,
                    backgroundColor: sideBarColor,
                    borderColor: sideBarDividerColor,
                    textColor: Color.black,
                    padding: EdgeInsets(top: 11, leading: 14, bottom: 11, trailing: 14),
                    expandedPickerId: $viewModel.expandedPickerId,
                    pickerId: "ApplicationStatusTypePickerID"
                )
                .frame(maxWidth: 120)
                
            }
            .zIndex(1100)
            
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
            
            LabeledTextField(
                header: "Requirements",
                placeHolderText: "3 Years of experience in SwiftUI",
                axis: .vertical,
                textFieldText: $viewModel.requirements
            )
            
            LabeledTextField(
                header: "Description",
                placeHolderText: "Develop great applications for MacOS devices!",
                axis: .vertical,
                textFieldText: $viewModel.jobDescription
            )
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    
    //MARK: - Web Preview
    var webPreview: some View {
        VStack(spacing: 8) {
            
            LabeledButton(
                selected: $viewModel.saveWebPage,
                labelText: "Save Offline Copy"
            )
            .padding(.top, 8)
            .opacity(isValidUrl(url: viewModel.listingLink) ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: viewModel.listingLink)
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

            WebpageSnapshotView(viewModel: webPageSnapShotViewModel,
                                currentURLString: $viewModel.listingLink,
                                isExpanded: $viewModel.webViewIsExpanded,
                                canExpand: !isCompact)
            
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }
    
    
    //MARK: - State Functions
    private func checkCanAddJob() {
        let newValue = !viewModel.companyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.jobTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard newValue != tbVM.entryViewAddJobButtonEnabled else { return }
        withAnimation(.easeInOut(duration: 0.25)) { tbVM.entryViewAddJobButtonEnabled = newValue }
    }
    
    
    private func addJobButtonPressed(_ newValue: Bool) {
        guard newValue else { return }
        withAnimation(.easeInOut(duration: 0.25), { tbVM.entryViewAddJobButtonEnabled = false })
        
        Task {
            do {
                try await viewModel.saveNewListing(with: dataContainer, webPageSnapShotViewModel)
                try await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    withAnimation {
                        tbVM.entryViewAddJobButtonPressed = false
                        dismiss()
                    }
                }
            } catch {
                print("Error, could not save job listing! \(error)")
                await MainActor.run {
                    tbVM.entryViewAddJobButtonPressed = false
                    withAnimation { tbVM.entryViewAddJobButtonEnabled = true }
                }
            }
        }
    }
    
    
}


//MARK: - View Model
extension JobEntryView {
    
    @MainActor
    final class ViewModel: ObservableObject {
                
        @Published var listingLink: String = ""
        @Published var jobTitle: String = ""
        @Published var companyName: String = ""
        @Published var applicationStatus: ApplicationStatus = .applied
        @Published var location: String = ""
        @Published var workLocationType: WorkLocationType = .onSite
        @Published var salaryRange: String = ""
        @Published var salaryNotListed: Bool = false
        @Published var salaryType: SalaryType = .yearly
        @Published var notes: String = ""
        @Published var requirements: String = ""
        @Published var jobDescription: String = ""
        
        @Published var saveWebPage: Bool = true
        @Published var expandedPickerId: String?
        @Published var showTooltip: Bool = false
        @Published var webViewIsExpanded: Bool = false
        @Published var autofillButtonDisabled: Bool = false
        

        func saveNewListing(with dataContainer: SwiftDataContainer,_ snapshotViewModel: WebpageSnapshotView.ViewModel) async throws {
            let newJob = JobListing(
                title: jobTitle,
                company: companyName,
                jobURL: URL(string: listingLink),
                location: location.isEmpty ? nil : location,
                payRange: salaryRange.isEmpty ? nil : location,
                notes: notes.isEmpty ? nil : notes,
                requirements: requirements.isEmpty ? nil : requirements,
                jobDescription: jobDescription.isEmpty ? nil : jobDescription,
                workLocationType: workLocationType,
                salaryType: salaryType,
            )
            
            do {
                if saveWebPage && isValidUrl(url: listingLink) {
                    let pdfResult = try await snapshotViewModel.exportPDF()
                    let archivePathExtension = try savePDFData(newJob, pdfResult)
                    newJob.saveDataFilePath = archivePathExtension
                }
                
                try dataContainer.insertJobListing(newJob)
            } catch { throw error }
        }
        
        
        private func savePDFData(_ listing: JobListing,_ data: Data) throws -> String {
            let dateFolder = "\(FileManagerUtility.dateFormatter.string(from: Date()))"
            let listingFolder = "\(listing.title) [\(listing.company)]"
            var pathExtension = "\(dateFolder)/\(listingFolder)"
            
            do {
                try FileManagerUtility.createNewDirectory(pathExtension)
                pathExtension.append("/archive.pdf")
                try FileManagerUtility.saveToDirectory(data, pathExtension)
                return pathExtension
            } catch { throw error }
        }
        
        
        func attemptAutofill(with snapshotViewModel: WebpageSnapshotView.ViewModel) {
            withAnimation { autofillButtonDisabled = true }
            Task {
                do {
                    let webPageText = try await snapshotViewModel.getPageText()
                    print(webPageText)
                } catch {
                    print("Error, could not fetch webpage text! \(error)")
                    
                    await MainActor.run { [weak self] in
                        withAnimation { self?.autofillButtonDisabled = false }
                    }
                }
            }
        }
        
        
        func toggleTooltip() {
            withAnimation(.easeInOut(duration: 0.25)) {
                showTooltip.toggle()
            }
        }
        
        func dismissOverlays() {
            withAnimation(.easeInOut(duration: 0.25)) {
                expandedPickerId = nil
                showTooltip = false
            }
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
    
    PreviewStruct()
        .environment(\.customDismiss, { })
        .sampleContainer()
    
}


fileprivate struct PreviewStruct: View {
    
    var body: some View {
        GeometryReader { proxy in
            JobEntryView(geometryProxy: proxy)
        }
        .sampleContainer()
        .environment(\.customDismiss, { })
        .frame(width: 900, height: 800)
    }
    
}

