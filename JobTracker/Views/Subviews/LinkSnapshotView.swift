//
//  LinkSnapshotView.swift
//  JobTracker
//

import SwiftUI
import WebKit

struct LinkSnapshotView: View {
    
    var pageURL: URL?
    
    var body: some View {
        Group {
            if pageURL != nil { webSnapshotView }
            else { emptyView }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(sideBarDividerColor, lineWidth: 2)
        )
    }
    
    
    private var webSnapshotView: some View {
        WebView(url: pageURL)
    }
    
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.gray.opacity(0.8))
            
            VStack(spacing: 6) {
                Text("No Preview Available")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.9))
                
                Text("Provide a link to see a web preview")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(sideBarColor)
    }
    
}

#Preview {
    
    let google = URL(string: "https://www.google.com")
    let apple = URL(string: "https://www.apple.org")
    
    LinkSnapshotView(pageURL: google)
        .frame(width: 400, height: 700)
        .background(Color.white)
}
