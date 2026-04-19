//
//  DashboardTopBarView.swift
//  JobTracker
//


import SwiftUI
import Combine

//MARK: - Top Bar
struct DashboardTopBarView: View {
    
    unowned let viewModel: ViewModel
    
    @FocusState.Binding var isSearchFieldFocused: Bool
    
    let geometryProxy: GeometryProxy
    let onSettingsTapped: () -> Void
    let onBackTapped: () -> Void
    
    private var schema: DashboardTopBarViewSchema { return viewModel.schemaStack.last! }
    
    var body: some View {
        viewForCurrentSchema
            .padding(.leading, 20)
            .frame(height: 70)
            .background(Color.white)
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.25), value: schema)
    }
    
    
    private var viewForCurrentSchema: some View {
        HStack(spacing: 8) {
            if schema.backButton {
                backButton
            }
            
            if schema == .backButtonWithJobEntryButton {
                jobEntryButton
            }
            
            if schema.searchField {
                searchField
            }
            
            if schema != .backButtonWithJobEntryButton {
                Spacer()
                    .frame(minWidth: 0)
            }
            
            if !schema.customButtons.isEmpty {
                ForEach(schema.customButtons, id: \.id) { buttonSchema in
                    ToolTipButton(icon: buttonSchema.icon, tooltip: buttonSchema.toolTip ?? "", action: {
                        viewModel.buttonPressed(with: buttonSchema.id)
                    })
                    .padding(.trailing, 5)
                }
            }
            
            if schema.profilePicture {
                profileIcon
            }
        }
    }
    
    
}


//MARK: - Reusable Elements
extension DashboardTopBarView {
    
    
    private var backButton: some View {
        Button {
            viewModel.backButtonTapped()
            onBackTapped()
        }
        label : {
            Image(systemName: "chevron.left")
                .font(.system(size: 22))
                .foregroundColor(.gray)
                .padding(15)
                .background(Color.clear.contentShape(Rectangle()))
                .frame(width: 45, height: 45)
        }
        .padding(.leading, -18)
        .transition(.opacity)
    }
    
    
    private var jobEntryButton: some View {
        LargeStylizedButton(action: { viewModel.entryViewAddJobButtonPressed = true },
                            imageName: "plus",
                            title: "Add Job",
                            isVisible: true,
                            disabled: !viewModel.entryViewAddJobButtonEnabled)
    }
    
    
    private var profileIcon: some View {
        Button(action: onSettingsTapped) {
            Text("JE")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(Color.white)
        }
        .frame(width: 45, height: 45)
        .background(Color.blue)
        .cornerRadius(25)
        .padding(.trailing, 30)
    }
    
    
    private var searchField: some View {
        TextField("", text: Binding(
            get: { viewModel.searchText },
            set: { viewModel.searchText = $0 }
        ))
        .font(.title3)
        .foregroundColor(.black)
        .padding(.leading, 44)
        .padding(.trailing, 16)
        .frame(height: 48)
        .cornerRadius(8)
        .containerRelativeFrame(.horizontal, { length, _ in return max(220, length / 3) })
        .textFieldStyle(.plain)
        .focusable(false)
        .focused($isSearchFieldFocused)
        .alignmentGuide(.firstTextBaseline, computeValue: { _ in 10})
        .modifier(TextFieldPlaceholderStyle(
            showPlaceHolder: viewModel.searchText.isEmpty,
            placeholder: "Search jobs, companies...",
            textColor: Color.gray,
            leadingOffset: 28,
            font: Font.system(size: 16, weight: .light)
        ))
        .overlay(
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
                    .padding(.leading, 14)
                    .padding(.bottom, 2)
                Spacer()
            })
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .transition(.opacity)
    }
    
    
    //MARK: - Tooltip Button
    fileprivate struct ToolTipButton: View {
        let icon: String
        let tooltip: String
        let action: () -> Void
        
        @State private var isHovered = false
        
        var body: some View {
            Button(action: action) {
                ZStack {
                    Color.white
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isHovered ? Color.black : Color.gray)
                }
                .frame(width: 44, height: 44)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHovered ? Color.gray.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: 1)
                )
                
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) { isHovered = hovering }
            }
            .overlay(alignment: .bottom) {
                if isHovered { toolTip }
            }
        }
        
        private var toolTip: some View {
            Text(tooltip)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(8)
                .transition(.opacity)
                .zIndex(1)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
                .offset(y: 28)
        }
        
    }
}


//MARK: - Schema Enum
extension DashboardTopBarView {
    
    enum DashboardTopBarViewSchema {
        case searchField,
             searchFieldWithFilterAndSort,
             backButton,
             backButtonWithJobEntryButton,
             backButtonWithWebLinkAndEdit,
             backButtonWithEdit,
             backButtonWithDeleteAndConfirm
        
        var searchField: Bool {
            switch self {
            case .searchField, .searchFieldWithFilterAndSort: return true
            default: return false
            }
        }
        
        var backButton: Bool {
            switch self {
            case .searchField, .searchFieldWithFilterAndSort: return false
            default: return true
            }
        }
        
        var profilePicture: Bool {
            return true
        }
        
        var customButtons: [(id: String, icon: String, toolTip: String?)] {
            switch self {
            case .searchFieldWithFilterAndSort:
                return [
                    (id: "Filter", icon: "line.3.horizontal.decrease", toolTip: "Filter"),
                    (id: "Sort", icon: "arrow.up.arrow.down", toolTip: "Sort")
                ]
            case .backButtonWithWebLinkAndEdit:
                return [
                    (id: "Open Link", icon: "arrow.up.right", toolTip: "Open Link"),
                    (id: "Edit", icon: "slider.horizontal.3", toolTip: "Edit")
                ]
            case .backButtonWithEdit:
                return [
                    (id: "Edit", icon: "slider.horizontal.3", toolTip: "Edit")
                ]
            default:
                return []
            }
        }
        
    }
    
}


//MARK: - View Model
extension DashboardTopBarView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var schemaStack: [DashboardTopBarViewSchema] = [.searchField]
        
        @Published var searchText: String = ""
        
        @Published var entryViewAddJobButtonEnabled: Bool = false
        @Published var entryViewAddJobButtonPressed: Bool = false
        
        var filterButtonPressed = { }
        var sortButtonPressed = { }
        var openLinkButtonPressed = { }
        var editButtonPressed = { }
        
        func backButtonTapped() {
            guard schemaStack.count > 1 else { return }
            schemaStack.removeLast()
        }
        
        func addSchema(_ schema: DashboardTopBarViewSchema) {
            schemaStack.append(schema)
        }
        
        func resetSchemaStack() {
            schemaStack = [.searchField]
        }
        
        func buttonPressed(with id: String) {
            switch id {
            case "Filter": filterButtonPressed()
            case "Sort": sortButtonPressed()
            case "Open Link": openLinkButtonPressed()
            case "Edit": editButtonPressed()
            default: break
            }
        }
        
    }
    
}

typealias DashboardTopBarViewModel = DashboardTopBarView.ViewModel


#Preview {
    ZStack {
        Color.blue
        
        DashboardTopBarView.ToolTipButton(icon: "arrow.up.right", tooltip: "Open Link") {
            //
        }
    } .frame(width: 200, height: 200)

}

