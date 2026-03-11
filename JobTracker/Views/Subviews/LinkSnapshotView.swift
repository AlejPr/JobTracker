//
//  LinkSnapshotView.swift
//  JobTracker
//

import SwiftUI
import WebKit
import Combine

struct LinkSnapshotView: View {
    
    @StateObject private var viewModel = ViewModel()
    @State var currentWebpageZoom: CGFloat = 1.0
    @Binding var currentURLString: String
    @Binding var isExpanded: Bool
    let canExpand: Bool
    
    var body: some View {
        Group {
            if viewModel.currentURL != nil { webSnapshotView }
            else { emptyView }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(sideBarDividerColor, lineWidth: 2)
        )
        .frame(minHeight: 600)
        
        //Update urlString in viewModel
        .onChange(of: currentURLString, { _, newValue in
            viewModel.updateURL(newValue)
        })
        .onAppear(perform: {
            viewModel.updateURL(currentURLString)
        })
    }
    
    private var webSnapshotView: some View {
        ZStack(alignment: .top) {
            CustomWebView(currentWebpageZoom: $currentWebpageZoom, listingURL: $viewModel.currentURL)
            
            HStack {
                if canExpand {
                    WebViewExpansionButton(isExpanded: $isExpanded)
                        .padding(.leading, -5)
                }
                
                Spacer()
                
                WebViewZoomControls (
                    onZoomIn: { currentWebpageZoom = min(currentWebpageZoom + 0.15, 3.0) },
                    onZoomOut: { currentWebpageZoom = max(currentWebpageZoom - 0.15, 0.5) }
                )
                .frame(height: 45)
            }
            .padding(.top, 12)
            .padding(.horizontal, 22)
            .zIndex(1000)
        }
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


//MARK: - Webview
extension LinkSnapshotView {
    
    struct CustomWebView: NSViewRepresentable {
        
        @State var currentWebView: WKWebView?
        @Binding var currentWebpageZoom: CGFloat
        @Binding var listingURL: URL?
        
        func makeNSView(context: Context) -> WKWebView {
            let config = WKWebViewConfiguration()
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            config.defaultWebpagePreferences = preferences
            
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.allowsMagnification = true
            webView.allowsBackForwardNavigationGestures = true
            
            webView.load(URLRequest(url: listingURL!))
            DispatchQueue.main.async { self.currentWebView = webView }
            return webView
        }
        
        func updateNSView(_ nsView: WKWebView, context: Context) {
            if let url = listingURL, nsView.url != url {
                nsView.load(URLRequest(url: url))
            }
            
            if nsView.pageZoom != currentWebpageZoom {
                zoomWithAnimation(nsView, to: currentWebpageZoom)
            }
        }
        
        //TODO: - Fix this shit
        private func zoomWithAnimation(_ webView: WKWebView, to newZoom: CGFloat) {
//            NSAnimationContext.runAnimationGroup { context in
//                context.duration = 0.3
//                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//                webView.animator().pageZoom = newZoom
//            }
            webView.pageZoom = newZoom
        }
        
    }
    
    struct WebViewExpansionButton: View {
        
        @Binding var isExpanded: Bool
        
        var body: some View {
            Button {
                withAnimation { isExpanded = !isExpanded }
            }
            label: {
                ZStack {
                    Color.white
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
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
    
}


//MARK: - View Model
extension LinkSnapshotView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var currentURL: URL? = nil
        @Published var currentImage: NSImage? = nil
        @Published var fetchError: String? = nil
        
        func updateURL(_ newURLString: String) {
            let trimmed = newURLString.trimmingCharacters(in: .whitespacesAndNewlines)
            currentURL = isValidUrl(url: trimmed) ? URL(string: trimmed) : nil

        }
        
    }
    
}




#Preview {
    
    PreviewStruct()
        .frame(width: 800, height: 600)
        .background(Color.white)
}


fileprivate struct PreviewStruct: View {
    static let google = "https://www.google.com"
    static let apple = "https://www.apple.org"
    @State var pageString = Self.google
    @State var isExpanded: Bool = false
    
    var body: some View {
        LinkSnapshotView(currentURLString: $pageString, isExpanded: $isExpanded, canExpand: true)
    }
    
}

