//
//  WebpageViewingUtilities.swift
//  JobTracker
//

import SwiftUI

//MARK: - Expansion Button
struct WebViewExpansionButton: View {
    
    @Binding var isExpanded: Bool
    var chevronImage: String = "chevron.left"
    var chevronSize: CGFloat = 16
    var frameSize: CGFloat = 44
    
    var body: some View {
        Button {
            withAnimation { isExpanded = !isExpanded }
        }
        label: {
            ZStack {
                Color.white
                    .frame(width: frameSize, height: frameSize)
                
                Image(systemName: chevronImage)
                    .font(.system(size: chevronSize, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(sideBarDividerColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }
    
}


struct WebViewZoomControls: View {
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onZoomOut) {
                Image(systemName: "minus.magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .frame(width: 44, height: 36)
                    .background(Color.white)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            
            Rectangle()
                .fill(sideBarDividerColor)
                .frame(width: 2)
            
            Button(action: onZoomIn) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 44, height: 36)
                    .foregroundStyle(Color.gray)
                    .background(Color.white)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(sideBarDividerColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }
}


#Preview {
}
