//
//  EnvironmentKeys.swift
//  JobTracker
//

import SwiftUI

extension EnvironmentValues {
    @Entry var customDismiss: () -> Void = { }
    @Entry var appendNavigationPath: (NavigationDestination, Bool) -> Void = { _, _  in }
    @Entry var topbarViewModel: DashboardTopBarView.ViewModel = DashboardTopBarView.ViewModel()
}
