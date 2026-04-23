//
//  JobDetailView.swift
//  JobTracker
//

import SwiftUI
import PDFKit
import Combine
import SwiftData


struct JobDetailView: View {
    
    @StateObject private var viewModel: ViewModel
    @EnvironmentObject var dashboardViewModel: DashboardTopBarViewModel
    @Environment(SwiftDataContainer.self) private var dataContainer

    @State var webViewIsExpanded: Bool = false
    @State var currentPDFZoom: CGFloat = 1
    
    var geometryProxy: GeometryProxy
    private var isCompact: Bool { geometryProxy.size.width < 900 }
    private var jobListing: JobListing { viewModel.jobListing }
    
    init(jobListing: JobListing, geometryProxy: GeometryProxy) {
        self.geometryProxy = geometryProxy
        _viewModel = StateObject(wrappedValue: ViewModel(jobListing: jobListing))
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView {
                
                Group {
                    if isCompact { verticalLayout }
                    else { horizontalLayout }
                }
                //.frame(minHeight: geometryProxy.size.height - 70)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: isCompact)
            }
            //.scrollDisabled(webViewIsExpanded)
            .background(Color.white)
            
            if let saveDataFilePath = jobListing.saveDataFilePath, let pdfData = viewModel.loadPDFData(with: saveDataFilePath) {
                
                ZStack(alignment: .topTrailing) {
                    PDFKitView(pdfData: pdfData,
                               currentPDFZoom: $currentPDFZoom)
                    
                    WebViewZoomControls(
                        onZoomIn: { currentPDFZoom = min(currentPDFZoom + 0.15, 3.0) },
                        onZoomOut: { currentPDFZoom = max(currentPDFZoom - 0.15, 0.5) }
                    )
                    .frame(maxHeight: 45)
                    .padding(20)
                    .padding(.trailing, 15)
                }
                .frame(maxWidth: webViewIsExpanded ? .infinity : 20, maxHeight: webViewIsExpanded ? .infinity : 20)
                .opacity(webViewIsExpanded ? 1 : 0)
                .cornerRadius(12)
                .padding(webViewIsExpanded ? 15 : 25)
                
                WebViewExpansionButton(
                    isExpanded: $webViewIsExpanded,
                    chevronImage: "chevron.up",
                    chevronSize: 22,
                    frameSize: 54
                )
                .padding(20)
                                
            }
        }
        .onAppear {
            dashboardViewModel.openLinkButtonPressed = viewModel.openListingLink
        }
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
        VStack(spacing: 15) {
            
            //Main Detail View
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
                        LabeledAttribute(title: "Applied", text: viewModel.formattedDate)
                        
                        LabeledAttribute(title: "Location", text: jobListing.location ?? "Not Provided")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        LabeledAttribute(
                            title: "Salary Range",
                            text: jobListing.salaryRange ?? "Not Provided"
                        )
                        
                        LabeledAttribute(
                            title: "Schedule",
                            text: { return "Full-Time"
                                //var parts: [String] = []
                                //if let schedule = jobListing.schedule { parts.append(schedule) }
                                //if let workType = jobListing.workLocationType { parts.append(workType.rawValue) }
                                //return parts.isEmpty ? "Not Provided" : parts.joined(separator: " · ")
                            }()
                        )
                    }
                    
                    Spacer()
                }
                
            }
            .modifier(ViewEffectsModifier())
            
            let fields: [(title: String, value: String?)] = [
                ("Notes", jobListing.notes),
                ("Requirements", jobListing.requirements),
                ("Description", jobListing.jobDescription)
            ]

            ForEach(fields.indices, id: \.self) { index in
                if let value = fields[index].value, !value.isEmpty {
                    HStack {
                        LabeledAttribute(title: fields[index].title,
                                         text: value,
                                         titleFont: .title2.weight(.medium),
                                         titleStyle: .black,
                                         textFont: .title2)
                        Spacer()
                    }
                    .modifier(ViewEffectsModifier())
                }
            }
            
        }
        
    }
    
    private struct ViewEffectsModifier: ViewModifier {
        
        public func body(content: Content) -> some View {
            content
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


//MARK: - PDFKit View
extension JobDetailView {
    
    private struct PDFKitView: NSViewRepresentable {
        
        let pdfData: Data
        @Binding var currentPDFZoom: CGFloat
        
        func makeCoordinator() -> Coordinator { Coordinator() }
        
        func makeNSView(context: Context) -> PDFView {
            let pdfView = PDFView()
            pdfView.autoScales = true
            pdfView.document = PDFDocument(data: pdfData)
            return pdfView
        }
        
        func updateNSView(_ pdfView: PDFView, context: Context) {
            context.coordinator.updatePDFZoom(with: pdfView, currentPDFZoom)
        }
        
        final class Coordinator {
            private var localPDFZoomModifier: CGFloat = 1

            func updatePDFZoom(with pdfView: PDFView,_ updatedZoom: CGFloat) {
                if updatedZoom < localPDFZoomModifier { pdfView.zoomOut(nil) }
                else if updatedZoom > localPDFZoomModifier { pdfView.zoomIn(nil) }
                localPDFZoomModifier = updatedZoom
            }
            
        }
        
    }
    
}


//MARK: - ViewModel
extension JobDetailView {
    
    @MainActor
    final private class ViewModel: ObservableObject {
        
        var jobListing: JobListing
        
        init(jobListing: JobListing) {
            self.jobListing = jobListing
        }
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: jobListing.timeStampApplied)
        }
        
        func loadPDFData(with filePath: String) -> Data? {
            do {
                return try FileManagerUtility.loadPDFData(filePath)
            }
            catch {
                NSLog("[JobDetailView] Could not load PDF data for \(filePath): \(error)")
                return nil
            }
        }
        
        func openListingLink() {
            guard let url = jobListing.jobURL else { return }
            NSWorkspace.shared.open(url)
        }
        
    }
    
}


#Preview {
    GeometryReader { proxy in
        JobDetailView(jobListing: JobListing.realJobListingSample, geometryProxy: proxy)
    }
    .frame(width: 900, height: 700)
    .environmentObject(DashboardTopBarViewModel())
}

