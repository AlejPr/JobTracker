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
        if navigationPath.last == .jobEntry {
            return .backButtonWithJobEntryButton
        }
        return .searchField
    }

    var body: some View {
        HStack(spacing: 8) {
            
            Spacer()
                .frame(width: 20)
            
            //Back Button
            if schema == .backButton || schema == .backButtonWithJobEntryButton {
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
                
                if schema == .backButtonWithJobEntryButton {
                    LargeStylizedButton(action: { addJobButtonPressed = true },
                                        imageName: "plus",
                                        title: "Add Job",
                                        isVisible: true,
                                        disabled: !addJobButtonEnabled
                    )
                }
                
            }
            
            else if schema == .searchField {
                searchField
            }
            
            Spacer()
            
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
        .frame(height: 70)
        .background(Color.white)
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: navigationPath)
        .animation(.easeInOut(duration: 0.25), value: schema)
    }
    
    
    private var searchField: some View {
        TextField("Search jobs, companies...", text: $searchText)
            .font(.title3)
            .foregroundColor(.gray)
            .padding(.leading, 44)
            .padding(.trailing, 16)
            .frame(height: 48)
            .background(Color.clear)
            .cornerRadius(8)
            .containerRelativeFrame(.horizontal, { length, _ in return length / 4 })
            .textFieldStyle(.plain)
            .focusable(false)
            .focused($isSearchFieldFocused)
            .alignmentGuide(.firstTextBaseline, computeValue: { _ in 10})
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
    
    
    enum DashboardTopBarViewSchema {
        case searchField, backButton, backButtonWithJobEntryButton
    }
    
    
}

//#Preview {
    //DashboardTopBarView()
        //.frame(width: 500)
//}
