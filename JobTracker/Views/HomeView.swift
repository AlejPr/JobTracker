//
//  HomeView.swift
//  JobTracker
//

import SwiftUI
import SwiftData
import Combine

private let minSidebarWidth: CGFloat = 230
private let maxSidebarWidth: CGFloat = 375
public let sideBarColor = Color(red: 248/255, green: 249/255, blue: 250/255).opacity(1)
public let sideBarDividerColor = Color(red: 227/255, green: 229/255, blue: 233/255)

struct HomeView: View {
    
    @StateObject private var viewModel: ViewModel
    @StateObject private var dashboardViewModel: DashboardTopBarView.ViewModel
    
    @FocusState private var isSearchFieldFocused: Bool
    
    init() {
        let dbVM = DashboardTopBarView.ViewModel()
        _dashboardViewModel = StateObject(wrappedValue: dbVM)
        _viewModel = StateObject(wrappedValue: ViewModel(dbVM))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            VStack(spacing: 0) {
                
                Sidebar(
                    selectedItem: $viewModel.sideBarSelectedItem,
                    onItemSelected: viewModel.sideBarItemSelected
                )
                .padding(.bottom, -5) //Prevents weird discoloration during animations
                
                //Divider
                Rectangle()
                    .fill(viewModel.shouldShowAddJobButton ? sideBarDividerColor : Color.clear)
                    .frame(height: 2)
                
                LargeStylizedButton(
                    action: viewModel.addNewJobTapped,
                    imageName: "plus",
                    title: "Add New Job",
                    isVisible: viewModel.shouldShowAddJobButton
                )
                .background(sideBarColor)
                .transition(.move(edge: .bottom))
            }
            .transition(.opacity)
            .containerRelativeFrame(.horizontal, { length, _ in
                if (length / 5) < minSidebarWidth { return minSidebarWidth }
                return min(length / 5, maxSidebarWidth)
            })
            
            //Fake Divider Bar
            Rectangle()
                .fill(sideBarDividerColor)
                .frame(width: 2)
                        
            
            GeometryReader { proxy in
                
                VStack(spacing: 0) {
                    
                    DashboardTopBarView(
                        viewModel: dashboardViewModel,
                        isSearchFieldFocused: $isSearchFieldFocused,
                        geometryProxy: proxy,
                        onSettingsTapped: viewModel.settingsTapped,
                        onBackTapped: viewModel.backButtonTapped,
                    )
                    .environmentObject(dashboardViewModel)
                    .zIndex(100)
                    
                    //Divider Bar
                    Rectangle()
                        .fill(sideBarDividerColor)
                        .frame(height: 2)
                    
                    //Navigation Stack
                    NavigationStack(path: $viewModel.navigationPathStack) {
                        
                        Color.green
                            .navigationBarBackButtonHidden(true)
                            .navigationDestination(for: NavigationDestination.self) { destination in
                                switch destination {
                                case .dashboard:
                                    Color.green
                                    
                                case .jobEntry:
                                    JobEntryView(geometryProxy: proxy)
                                        .environment(\.customDismiss, viewModel.backButtonTapped)
                                        .transition(.move(edge: .bottom))
                                    
                                case .jobListings:
                                    ListJobsView()
                                    
                                case .jobListing(let listing):
                                    JobDetailView(jobListing: listing, geometryProxy: proxy)
                                        .id(listing.id)
                                    
                                case .statistics: Color.orange
                                case .calendar: Color.purple
                                case .documents: Color.blue //Placeholder
                                }
                            }
                    }
                    .environment(\.topbarViewModel, dashboardViewModel)
                    .environment(\.appendNavigationPath, viewModel.appendToNavigationStack(_:animated:))

                }
                
            }
            .frame(minWidth: 450, minHeight: 450)
        }
        .onTapGesture { isSearchFieldFocused = false }
    }
    
    enum NavigationDestination: Hashable {
        case dashboard
        case jobEntry
        case jobListings
        case statistics
        case calendar
        case documents
        case jobListing(JobListing)
    }
    
}


//MARK: - Sidebar Item Enum
enum SidebarItem: String, CaseIterable {
    case dashboard
    case jobListings
    case statistics
    case calendar
    case documents
    
    var icon: String {
        switch self {
        case .dashboard: return "arrow.up.right"
        case .jobListings: return "doc.text"
        case .statistics: return "chart.bar"
        case .calendar: return "calendar"
        case .documents: return "folder"
        }
    }
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .jobListings: return "Job Listings"
        case .statistics: return "Statistics"
        case .calendar: return "Calendar"
        case .documents: return "Documents"
        }
    }
    
    var destination: HomeView.NavigationDestination {
        switch self {
        case .dashboard: return .dashboard
        case .jobListings: return .jobListings
        case .statistics: return .statistics
        case .calendar: return .calendar
        case .documents: return .documents
        }
    }
}


//MARK: - Sidebar
struct Sidebar: View {
    @Binding var selectedItem: SidebarItem
    let onItemSelected: (SidebarItem) -> Void
    
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
                ForEach(SidebarItem.allCases, id: \.self) { item in
                    SidebarItemView(
                        item: item,
                        isSelected: selectedItem == item
                    ) {
                        onItemSelected(item)
                    }
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
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(item.title)
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


//MARK: - ViewModel
extension HomeView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var navigationPathStack: [NavigationDestination] = []
        @Published var sideBarSelectedItem: SidebarItem = .dashboard
        @Published var shouldShowAddJobButton: Bool = true
        
        unowned let tbVM: DashboardTopBarView.ViewModel
                
        init(_ dashBoardTopBarViewModel: DashboardTopBarView.ViewModel) {
            self.tbVM = dashBoardTopBarViewModel
        }
        
        func sideBarItemSelected(_ item: SidebarItem) {
            if item == .documents {
                FileManagerUtility.openDocumentsDirectory()
                return
            }

            sideBarSelectedItem = item
            navigationPathStack = []
            tbVM.resetSchemaStack()
            appendToNavigationStack(item.destination, animated: false)
            showAddJobButton()
        }
        
        func settingsTapped() {
            // TODO: Navigate to settings
            print("settings tapped!")
        }
        
        func backButtonTapped() {
            if navigationPathStack.last == .jobEntry { showAddJobButton() }
            removeFromNavigationStack()
        }
        
        func addNewJobTapped() {
            hideAddJobButton()
            appendToNavigationStack(.jobEntry)
        }
        
        private func showAddJobButton() {
            withAnimation { shouldShowAddJobButton = true }
        }
        
        private func hideAddJobButton() {
            withAnimation { shouldShowAddJobButton = false }
        }
        
        
        func appendToNavigationStack(_ newDestination: NavigationDestination, animated: Bool = true) {
            switch newDestination {
            case .jobEntry: tbVM.addSchema(.backButtonWithJobEntryButton)
            case .jobListings: tbVM.addSchema(.searchFieldWithFilterAndSort)
            case .jobListing(let listing):
                if listing.jobURL == nil { tbVM.addSchema(.backButtonWithEdit) }
                else { tbVM.addSchema(.backButtonWithWebLinkAndEdit) }
            default: break
            }
            
            if animated {
                withAnimation { navigationPathStack.append(newDestination) }
            }
            else { navigationPathStack.append(newDestination) }
        }
        
        
        func removeFromNavigationStack() {
            withAnimation { navigationPathStack.removeLast() }
        }
        
    }
}


typealias NavigationDestination = HomeView.NavigationDestination


//MARK: - Preview
#Preview {
    HomeView()
        .frame(width: 1000, height: 700)
}

