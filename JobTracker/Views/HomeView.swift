//
//  HomeView.swift
//  JobTracker
//

import SwiftUI
import SwiftData

private let minSidebarWidth: CGFloat = 230
private let sideBarColor = Color(red: 248/255, green: 249/255, blue: 250/255).opacity(1)
public let sideBarDividerColor = Color(red: 227/255, green: 229/255, blue: 233/255)

@Query fileprivate var jobListings: [JobListing]

struct HomeView: View {
    
    @State private var visibility: NavigationSplitViewVisibility = .automatic
    @State private var sideBarSelectedItem: SidebarItem = .dashboard
    @State private var shouldShowAddJobButton: Bool = true
    @State private var navigationPath = [String]()
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            
            VStack(spacing: 0) {
                Sidebar(selectedItem: $sideBarSelectedItem, selectedItemUpdated: {
                    navigationPath.append(sideBarSelectedItem.rawValue)
                })
                
                //Divider
                Rectangle()
                    .fill(sideBarDividerColor)
                    .frame(height: 1.5)
                
                AddNewJobButtonView(action: {
                    withAnimation(.spring(response: 0.5)) { shouldShowAddJobButton.toggle() }
                    navigationPath.append("AddNewJobView")
                    
                }, isVisible: $shouldShowAddJobButton)
                .background(sideBarColor)
            }
            .containerRelativeFrame(.horizontal, { length, _ in
                if (length / 5) < minSidebarWidth { return minSidebarWidth }
                else { return length / 5 }
            })
            
            //Fake Divider Bar
            Rectangle()
                .fill(sideBarDividerColor)
                .frame(width: 1.5)
                        
            
            VStack(spacing: 0) {
                
                DashboardTopBarView(navigationPath: $navigationPath, isSearchFieldFocused: $isSearchFieldFocused) {
                    //Settings Tapped
                    print("settings tapped!")
                    
                } returnButtonAction: {
                    
                    guard let last = navigationPath.last else { return }
                    switch last {
                    case "AddNewJobView":
                        withAnimation(.spring(response: 0.5)) { shouldShowAddJobButton = true }
                        navigationPath.removeLast()
                    default: navigationPath.removeLast()
                    }

                }
                
                //Divider Bar
                Rectangle()
                    .fill(sideBarDividerColor)
                    .frame(height: 1.5)
                
                //Navigation Stack
                NavigationStack(path: $navigationPath) {
                    Color.green
                    .navigationBarBackButtonHidden(true)
                    .navigationDestination(for: String.self) { string in
                        switch string {
                            
                        case "AddNewJobView":
                            AddNewJobView()
                            
                        case "jobListings":
                            ListJobsView()
                            
                        default: Color.green
                        }
                    }
                    
                }

            }
             
        }
        
        
        .onTapGesture {
            isSearchFieldFocused = false
        }
        
    }
    
}


//MARK: - Sidebar Item Enum
enum SidebarItem: String, CaseIterable {
    case dashboard
    case jobListings
    case statistics
    case calendar
    case documents
}


//MARK: - Sidebar
struct Sidebar: View {
        
    @Binding var selectedItem: SidebarItem
    let selectedItemUpdated: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // App Title
            Text("JobTracker")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            
            // Navigation Items
            VStack(alignment: .leading, spacing: 8) {
                SidebarItemView(
                    item: .dashboard,
                    icon: "arrow.up.right",
                    title: "Dashboard",
                    isSelected: selectedItem == .dashboard
                ) {
                    selectedItem = .dashboard
                    selectedItemUpdated()
                }
                
                SidebarItemView(
                    item: .jobListings,
                    icon: "doc.text",
                    title: "Job Listings",
                    isSelected: selectedItem == .jobListings
                ) {
                    selectedItem = .jobListings
                    selectedItemUpdated()
                }
                
                SidebarItemView(
                    item: .statistics,
                    icon: "chart.bar",
                    title: "Statistics",
                    isSelected: selectedItem == .statistics
                ) {
                    selectedItem = .statistics
                    selectedItemUpdated()
                }
                
                SidebarItemView(
                    item: .calendar,
                    icon: "calendar",
                    title: "Calendar",
                    isSelected: selectedItem == .calendar
                ) {
                    selectedItem = .calendar
                    selectedItemUpdated()
                }
                
                SidebarItemView(
                    item: .documents,
                    icon: "folder",
                    title: "Documents",
                    isSelected: selectedItem == .documents
                ) {
                    selectedItem = .documents
                    selectedItemUpdated()
                }
            }
            .padding(.horizontal, 12)
            Spacer()
            
        }
        .background(sideBarColor)
        
    }
    
}


//MARK: - Sidebar Item View
struct SidebarItemView: View {
    let item: SidebarItem
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .blue : Color(red: 75/255, green: 85/255, blue: 99/255))
                
                 Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : sideBarColor)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


//MARK: - Add New Job Button View
struct AddNewJobButtonView: View {
    let action: () -> Void
    let buttonSidePadding: CGFloat = 15
    let containerHeight: CGFloat = 90
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.leading, 10)
                    
                    Text("Add New Job")
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
            .frame(minWidth: minSidebarWidth)
            .frame(height: containerHeight)
            .transition(.move(edge: .bottom))

        }
        
    }

    
}


//MARK: - Top Bar
struct DashboardTopBarView: View {
    @State var searchText: String = ""
    @Binding var navigationPath: [String]
    @FocusState.Binding var isSearchFieldFocused: Bool
    let profileCircleAction: () -> Void
    let returnButtonAction: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            
            Spacer()
                .frame(width: 20)
            
            //Back Button
            if !navigationPath.isEmpty, navigationPath.last == "AddNewJobView" {
                Button(action: returnButtonAction) {
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
            
            //Search Field
            else {
                TextField("Search jobs, companies...", text:$searchText)
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
            
            Spacer()
            
            Button(action: profileCircleAction) {
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
    }
    
}





#Preview {
    HomeView()
        .frame(width: 1000, height: 700)
}

