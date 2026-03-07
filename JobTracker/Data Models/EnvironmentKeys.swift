//
//  EnvironmentKeys.swift
//  JobTracker
//

import SwiftUI

extension EnvironmentValues {
    @Entry var customDismiss: () -> Void = { }
    @Entry var navigationPathStack: [HomeView.NavigationDestination] = []
}
