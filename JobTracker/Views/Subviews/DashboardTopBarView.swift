//
//  DashboardTopBarView.swift
//  JobTracker
//


import SwiftUI

//MARK: - Top Bar
struct DashboardTopBarView: View {
    
    @Binding var searchText: String
    @Binding var navigationPath: [HomeView.NavigationDestination]
    
    @Binding var addJobButtonEnabled: Bool
    @Binding var addJobButtonPressed: Bool
    
    @FocusState.Binding var isSearchFieldFocused: Bool
    
    let geometryProxy: GeometryProxy
    let onSettingsTapped: () -> Void
    let onBackTapped: () -> Void
    
    private var isCompact: Bool { return geometryProxy.size.width < 900 }
    
    private var schema: DashboardTopBarViewSchema {
        switch navigationPath.last {
        case .jobEntry: .backButtonWithJobEntryButton
        case .jobListings: .searchFieldWithFilterAndSort
        default: .searchField
        }
    }

    var body: some View {
        viewForCurrentSchema
            .padding(.leading, 20)
            .frame(height: 70)
            .background(Color.white)
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.25), value: navigationPath)
            .animation(.easeInOut(duration: 0.25), value: schema)
    }
    
    
    private var viewForCurrentSchema: some View {
        HStack(spacing: 8) {
            if [.backButton, .backButtonWithJobEntryButton].contains(schema) {
                backButton
                if schema == .backButtonWithJobEntryButton { jobEntryButton }
            }
            
            else if [.searchField, .searchFieldWithFilterAndSort].contains(schema) {
                searchField
                
                if schema == .searchFieldWithFilterAndSort {
                    Spacer()
                        .frame(minWidth: 0)
                        .background(Color.red)
                    filterButtons
                }
            }
            
            if schema != .searchFieldWithFilterAndSort { Spacer() }
            
            profileIcon
        }
    }
    
    
    private var backButton: some View {
        Button(action: onBackTapped) {
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
        LargeStylizedButton(action: { addJobButtonPressed = true },
                            imageName: "plus",
                            title: "Add Job",
                            isVisible: true,
                            disabled: !addJobButtonEnabled)
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
        TextField("", text: $searchText)
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
                showPlaceHolder: searchText.isEmpty,
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
    
    
    private var filterButtons: some View {
        HStack(spacing: 10) {
            ToolTipButton(icon: "line.3.horizontal.decrease", tooltip: "Filter") {
                //
            }
            
            ToolTipButton(icon: "arrow.up.arrow.down", tooltip: "Sort") {
                //
            }
        }
        .padding(.trailing, 5)
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
                .frame(width: 40)
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
    
    
    //MARK: - Schema Enum
    enum DashboardTopBarViewSchema {
        case searchField,
             searchFieldWithFilterAndSort,
             backButton,
             backButtonWithJobEntryButton
    }
    
    
}

#Preview {
    ZStack {
        Color.blue
        
        DashboardTopBarView.ToolTipButton(icon: "line.3.horizontal.decrease", tooltip: "Filter") {
            //
        }
    } .frame(width: 200, height: 200)

}
